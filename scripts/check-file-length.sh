#!/usr/bin/env bash
set -euo pipefail

readonly MAX_LINES=150
root=${1:-"$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"}
cd -- "$root"

# Migrations and generated files are excluded explicitly, not by filename guesswork.
readonly EXEMPT_PATHS=(
    '*/database/migrations/*'
    '*/bootstrap/cache/*'
    '*/.next/*'
    '*/src/generated/*'
)
readonly SCAN_ROOTS=(app src routes tests backend/app backend/routes backend/tests frontend/src frontend/tests)
failed=0
checked=0

is_exempt() {
    local path=$1 pattern
    for pattern in "${EXEMPT_PATHS[@]}"; do
        if [[ "$path" == $pattern ]]; then
            return 0
        fi
    done
    return 1
}

count_code_lines() {
    awk '
    function scan(line,    i, c, pair, code) {
        code = (quote != "")
        for (i = 1; i <= length(line); i++) {
            c = substr(line, i, 1); pair = substr(line, i, 2)
            if (block) { if (pair == "*/") { block = 0; i++ }; continue }
            if (quote != "") {
                code = 1
                if (c == "\\") { i++; continue }
                if (c == quote) quote = ""
                continue
            }
            if (pair == "//" || c == "#") break
            if (pair == "/*") { block = 1; i++; continue }
            if (c == "\042" || c == "\047" || c == "`") quote = c
            if (c !~ /[[:space:]]/) code = 1
        }
        return code
    }
    { count += scan($0) }
    END { print count + 0 }
    ' "$1"
}

check_file() {
    local path=$1 lines
    if is_exempt "$path"; then return; fi
    lines=$(count_code_lines "$path")
    checked=$((checked + 1))
    if ((lines > MAX_LINES)); then
        printf 'FAIL: %s: %s code lines (limit %s)\n' "$path" "$lines" "$MAX_LINES" >&2
        failed=1
    fi
}

for directory in "${SCAN_ROOTS[@]}"; do
    if [[ ! -d "$directory" ]]; then continue; fi
    # NUL separators preserve spaces and newlines in filenames.
    while IFS= read -r -d '' path; do
        check_file "$path"
    done < <(find "$directory" -type f \( -name '*.php' -o -name '*.ts' -o -name '*.tsx' \
        -o -name '*.js' -o -name '*.jsx' -o -name '*.sh' \) -print0)
done

if ((failed)); then exit 1; fi
printf 'PASS: %s source files checked (limit %s code lines per file).\n' "$checked" "$MAX_LINES"

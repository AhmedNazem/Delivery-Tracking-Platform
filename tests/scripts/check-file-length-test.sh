#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
checker="$project_root/scripts/check-file-length.sh"
sandbox=$(mktemp -d)
trap 'rm -rf -- "$sandbox"' EXIT

if [[ ! -f "$checker" ]]; then
    echo "FAIL: length checker has not been implemented" >&2
    exit 1
fi

write_lines() {
    local path=$1 count=$2
    mkdir -p -- "$(dirname -- "$path")"
    awk -v count="$count" 'BEGIN { for (i = 0; i < count; i++) print "statement();" }' > "$path"
}

expect_pass() {
    if ! bash "$checker" "$sandbox" > "$sandbox/output" 2>&1; then
        cat "$sandbox/output"
        exit 1
    fi
}

expect_failure() {
    local expected=$1 status=0
    bash "$checker" "$sandbox" > "$sandbox/output" 2>&1 || status=$?
    if [[ "$status" -ne 1 ]] || ! grep -Fq -- "$expected" "$sandbox/output"; then
        echo "FAIL: expected exit 1 and message containing $expected"
        cat "$sandbox/output"
        exit 1
    fi
}

expect_pass
write_lines "$sandbox/backend/app/Boundary.php" 150
expect_pass
write_lines "$sandbox/backend/app/Boundary.php" 151
expect_failure 'backend/app/Boundary.php: 151 code lines'
write_lines "$sandbox/backend/app/Boundary.php" 150

for folder in app src routes tests backend/routes backend/tests frontend/src frontend/tests; do
    write_lines "$sandbox/$folder/Long file.ts" 151
    expect_failure "$folder/Long file.ts: 151 code lines"
    rm -- "$sandbox/$folder/Long file.ts"
done

write_lines "$sandbox/frontend/src/Comments.ts" 150
for ((i = 0; i < 200; i++)); do
    printf '\n// comment\n/* block\n * comment\n */\n' >> "$sandbox/frontend/src/Comments.ts"
done
expect_pass
printf '%s\n' 'const url = "https://example.com/*path*/";' >> "$sandbox/frontend/src/Comments.ts"
expect_failure 'frontend/src/Comments.ts: 151 code lines'
rm -- "$sandbox/frontend/src/Comments.ts"

write_lines "$sandbox/backend/app/Mixed.php" 150
printf '%s\n' '/* comment */ statement(); // comment' >> "$sandbox/backend/app/Mixed.php"
expect_failure 'backend/app/Mixed.php: 151 code lines'
rm -- "$sandbox/backend/app/Mixed.php"

write_lines "$sandbox/backend/database/migrations/CreateShipments.php" 200
write_lines "$sandbox/backend/bootstrap/cache/config.php" 200
write_lines "$sandbox/frontend/.next/generated.ts" 200
write_lines "$sandbox/frontend/src/generated/client.ts" 200
write_lines "$sandbox/backend/app/Notes.md" 200
expect_pass

if bash "$checker" "$sandbox/missing" > "$sandbox/output" 2>&1; then
    echo 'FAIL: nonexistent root must fail' >&2
    exit 1
fi

echo 'PASS: boundaries, scan roots, spaces, comments, strings, exclusions, and invalid root'

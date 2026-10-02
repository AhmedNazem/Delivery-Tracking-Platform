#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)
hook="$root/.githooks/pre-commit"
if [[ ! -f "$hook" ]]; then
    echo 'FAIL: pre-commit hook has not been implemented' >&2
    exit 1
fi

sandbox=$(mktemp -d)
trap 'rm -rf -- "$sandbox"' EXIT
mkdir -p "$sandbox/bin"
cat > "$sandbox/bin/gitleaks" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$CALL_LOG"
exit "${SCAN_STATUS:-0}"
STUB
chmod +x "$sandbox/bin/gitleaks"
export CALL_LOG="$sandbox/arguments"
export PATH="$sandbox/bin:$PATH"

bash "$hook"
expected=$(printf '%s\n' git --pre-commit --staged --redact --no-banner)
if [[ "$(cat "$CALL_LOG")" != "$expected" ]]; then
    echo 'FAIL: hook must scan staged changes and redact findings' >&2
    exit 1
fi

for failure in 1 2; do
    status=0
    SCAN_STATUS=$failure bash "$hook" >/dev/null 2>&1 || status=$?
    if [[ "$status" -ne "$failure" ]]; then
        echo "FAIL: scanner exit $failure must block the commit" >&2
        exit 1
    fi
done

echo 'PASS: staged scan, redaction, success, findings, and scanner errors'

# Local repository hooks

Install Gitleaks from its [official project](https://github.com/gitleaks/gitleaks).
Use a version that supports `gitleaks git --pre-commit --staged` (8.19 or newer).
Ensure `gitleaks version` works in the shell used by Git. On this Windows checkout,
a checksum-verified portable v8.24.3 is installed in `.tools/gitleaks/`; this local
folder is ignored by Git and must not be committed. Other clones need their own
installation. Version 8.24.3 is a pinned compatibility baseline, not a claim that
it is the newest release.

From the repository root, activate the tracked hook:

```bash
git config --local core.hooksPath .githooks
chmod +x .githooks/pre-commit
```

Check for an existing hooksPath or custom pre-commit hook before activating this
directory; switching hooksPath replaces which directory Git uses for all hooks.
On Windows, Git Bash executes the hook. On Unix, the executable permission is
required. A fresh clone does not automatically activate local hook configuration.
If Windows also has WSL, run commits from Git Bash or ensure Git's `bin` and
`usr/bin` directories precede Windows' WSL Bash launcher on PATH. Otherwise
`env bash` can resolve to an unavailable WSL environment.

The hook scans staged changes and blocks commits if Gitleaks finds potential
secrets, cannot run, or reports an error. Diagnostics redact secret values.
Inspect findings and correct the staged files; do not disable the scanner to
force the commit through. A local hook is not a substitute for CI scanning or
GitHub push protection, which are separate roadmap tasks.

Run the hook behavior tests with:

```bash
bash tests/scripts/pre-commit-test.sh
```

These tests simulate scanner responses. Also verify the real scanner against a
temporary repository with a clean staged file and a fake secret; do not use real
credentials. Never infer complete security coverage from a successful scan.

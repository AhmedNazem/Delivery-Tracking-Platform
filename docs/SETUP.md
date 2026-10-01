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

## GitHub repository security and dependency updates

On 2026-10-02, the GitHub API confirmed this repository is public and has secret
scanning and push protection enabled. Private vulnerability reporting was enabled
and verified, so the private reporting channel described in SECURITY.md is active.

The tracked PR template prompts reviewers for the problem, validation, and risks.
Dependabot currently checks GitHub Actions weekly and limits open update PRs to
five. It becomes active after `.github/dependabot.yml` reaches the default branch.
Add Composer for `/backend` and npm for `/frontend` when their package manifests
exist; do not configure update jobs for nonexistent manifests.

Repository settings are separate from local files: cloning the project does not
copy GitHub settings, and local commits do not publish templates or activate
Dependabot until pushed. Dependabot opens proposals; maintainers review and merge
them, rather than automatically accepting updates.

## Main branch and planning templates

Work on a short-lived branch and open a pull request to `main`. The task 0.9
protection requires the `File length check` job, an up-to-date branch, a PR,
resolved review conversations, and linear history. Force pushes and branch
deletion are disallowed; administrators follow the same requirements.

The approval count is zero for this solo learning project: a PR is required, but
the author is not blocked waiting for a second person's approval. Self-review and
AI review still apply. Use squash merge to keep the history linear.

The CI workflow currently exists locally and must be uploaded on a feature branch
so GitHub can run the required check on the PR. A pending check is not a passing
check. Do not disable protection to push directly to `main`.

The issue templates cover reproducible bugs and features with acceptance criteria.
Their configuration directs security reports to private advisories. Templates
become available after reaching the default branch.

`docs/adr/template.md` records context, alternatives, the decision, consequences,
and verification. See `docs/adr/README.md` for naming and replacement rules.

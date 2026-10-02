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

## Laravel backend (task 1.1)

The backend uses Laravel 12, with PHP 8.3.35 and Composer 2.10.3 installed locally
in the ignored `.tools` folder. Other clones must install PHP 8.3 and Composer or
use the Docker environment introduced in task 1.2. Tool archives were verified
against their publishers' checksums before execution.

From the repository root in PowerShell on this checkout:

```powershell
& .tools/php/php.exe backend/artisan --version
& .tools/php/php.exe backend/artisan route:list
& .tools/php/php.exe backend/artisan serve --host=127.0.0.1 --port=8000
```

For tests, run from `backend` so Laravel's test runner resolves PHPUnit correctly:

```powershell
Push-Location backend
& ../.tools/php/php.exe artisan test
Pop-Location
```

Composer installs should run with the portable PHP directory on the current
process PATH. Its subprocesses invoke `php` themselves. This does not require
changing the machine's global PATH:

```powershell
$env:PATH = (Join-Path (Get-Location) '.tools/php') + ';' + $env:PATH
$env:COMPOSER_IPRESOLVE = '4'
& .tools/php/php.exe .tools/composer/composer.phar --working-dir=backend install
```

On this checkout, the ignored `backend/.env` has a generated application key and
uses file sessions, file cache, and synchronous queues to boot without a database.
The committed `.env.example` remains the standard scaffold example, with no real
secrets. Its full project configuration is task 1.5. Default migration files are
present but have not been run; MySQL setup is task 1.2 and schema work is step 3.

The welcome page is a minimal boot check, not the Next.js product interface.
No auth or shipment endpoints have been implemented. API/Sanctum setup comes
later; `/up` is the framework's basic liveness endpoint, not a database readiness
check. Laravel's default unit test only checks `true`; meaningful behavior tests
will accompany actual features.

## Docker backend environment (task 1.2)

Five tracked files define this environment: `docker-compose.yml` coordinates the
services, `docker/php/Dockerfile` builds PHP with Laravel's needed extensions,
`docker/nginx/default.conf` forwards requests to PHP-FPM, `.dockerignore` excludes
unneeded build context, and the root `.env.example` documents Docker variables.

On a new checkout, copy root `.env.example` to root `.env` and replace its demo
passwords. Also copy `backend/.env.example` to `backend/.env`. These are two
different files: Compose reads the root file; Laravel reads the backend file.
This checkout already has both ignored files and generated local credentials.

Start Docker Desktop with Linux containers, then from the repository root:

```bash
docker compose config --quiet
docker compose up --build -d
docker compose exec app php artisan key:generate
docker compose exec app php artisan test
docker compose exec nginx nginx -t
docker compose exec app php artisan tinker --execute="dump(DB::select('SELECT 1 AS healthy'));"
```

Generate the Laravel key only on initial setup when APP_KEY is empty; the current
checkout already has one. Open `http://localhost:8000` after PHP finishes its
Composer install. MySQL is internal to the Compose network, not exposed to the
host. PHP uses the regular application database user, not the MySQL root user.

The app waits for an authenticated MySQL health check. The first database startup
has a three-minute grace period before failed checks count toward its retry limit.
Nginx waits for the app
container to start, but PHP still needs time to finish Composer before accepting
requests; a brief initial 502 is possible. Check `docker compose logs app` if it
persists. On Windows, Composer autoload generation through the bind mount can take
several minutes on the first start. Sessions and cache use files until the database
roadmap is implemented.

Run migrations only when the relevant database tasks have been reviewed; startup
does not run migrations, seeders, or generate/rotate application keys implicitly.

`docker compose down` stops this stack and preserves the named MySQL data volume.
Do not add `--volumes` unless you explicitly intend to delete its local database.
Rebuilding containers does not reset database passwords stored in an existing
volume; change them through MySQL or deliberately recreate disposable data.

This setup is for local development: source code is bind-mounted, Composer runs
on startup, and APP_DEBUG follows the local Laravel file. Production images,
permissions, TLS, queues, and deployment controls are separate roadmap work.
The frontend service is added when a Next.js project exists in step 8.

Validation on this checkout: the Docker build and Nginx configuration check passed,
both scaffold tests passed inside the PHP container, and Laravel queried MySQL
successfully with `SELECT 1 AS healthy`. The welcome page returned HTTP 200;
Nginx returned 403 for `/.env` and 404 for `/other.php`.

Simple request flow: browser -> Nginx -> PHP/Laravel -> MySQL -> response.
Like a shop, Nginx receives the customer, Laravel handles the order, and MySQL
keeps the records. `DB_HOST=mysql` uses the database service's name. Using
`localhost` here would point back to the PHP container and fail to reach MySQL.
Serving only `backend/public` keeps application files outside the web root.

## PHP formatting (task 1.3)

`backend/pint.json` selects the `psr12` preset required by the blueprint. Pint is
already installed as a development dependency; no package or lock-file changes
were needed. From the repository root:

```bash
docker compose exec app vendor/bin/pint
docker compose exec app vendor/bin/pint --test
```

The first command fixes formatting. The second checks it without editing files
and fails if formatting needs correction. For the portable Windows PHP runtime,
run these from `backend/`:

```powershell
& ../.tools/php/php.exe vendor/bin/pint
& ../.tools/php/php.exe vendor/bin/pint --test
```

Like a team using one document template, PSR-12 keeps everyone's PHP layout
consistent. Pint checks layout, not whether shipment rules or permissions work.
Behavior tests remain necessary. CI integration is task 1.5.

Task inventory: one new file, `backend/pint.json`; six modified files: the User
model, the users/cache/jobs migrations, this setup document, and the task tracker.
The model now uses one trait per statement; the migrations use PSR-12 anonymous
class formatting. Their database definitions and model behavior are unchanged.
The migrations have not been run. Pint's check and both scaffold tests passed.

# Delivery Tracking Platform — Blueprint

A logistics and delivery management platform: dispatchers create and assign shipments, drivers update delivery status from the field, customers track parcels by tracking number.

**Stack:** Laravel 11 (PHP 8.3) · MySQL 8 · Next.js (App Router) + React + TypeScript · i18next + react-i18next · Laravel Sanctum · Docker Compose · GitHub Actions

**Repository:** public. Everything in this document assumes that anyone can read the code and the git history.

---

## 1. Engineering Rules (non-negotiable)

These apply to every file from the first commit.

### 1.1 File size limit
- **No source file exceeds 150 lines of code** (blank lines and comments excluded from the count is acceptable; the target is still well under 150).
- When a file approaches 120 lines, plan the split. When it passes 150, refactor before merging.
- Enforced automatically: a CI step (`scripts/check-file-length.sh`) fails the build if any file in `app/`, `src/`, `routes/`, `tests/` exceeds 150 lines. Migrations and generated files are the only exemptions, listed explicitly in the script.

### 1.2 Refactoring policy
- Refactor in a **separate commit** from feature work (`refactor: ...`).
- Triggers: file over 150 lines, method over 20 lines, class with more than one reason to change, duplicated logic in 3+ places (rule of three).
- Never refactor without passing tests first and passing tests after.

### 1.3 Clean code
- Names reveal intent (`AssignDriverToShipment`, not `Handler2`).
- Methods do one thing, max ~20 lines, max 3 parameters (use a DTO beyond that).
- No magic values: statuses, roles, and limits live in enums or config.
- No commented-out code, no dead code, no `TODO` without an issue number.
- Early returns over nested conditionals.
- Comments explain *why*, never *what*.

### 1.4 SOLID, applied concretely
| Principle | How it appears here |
|---|---|
| **S**ingle Responsibility | Controllers only translate HTTP ↔ application layer. One Action class per use case. |
| **O**pen/Closed | New status transitions or notification channels are added by new classes, not by editing `switch` statements. |
| **L**iskov Substitution | Any `NotificationChannel` implementation can replace another without callers noticing. |
| **I**nterface Segregation | Small focused contracts (`ShipmentRepository`, `NotificationChannel`) instead of one large service interface. |
| **D**ependency Inversion | Actions depend on interfaces bound in a service provider, never on Eloquent models directly where a repository exists. |

### 1.5 Other practices
- PSR-12 via Laravel Pint; ESLint + Prettier for the frontend; PHPStan level 8; TypeScript `strict: true`.
- Conventional Commits (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).
- Trunk-based flow with short-lived feature branches and PRs, even when working solo (PR description doubles as documentation).
- Tests accompany every feature. Coverage target: 80% on the application layer.

### 1.6 Learning protocol (the developer must understand every line)

This project exists to be explained in a job interview, so **no step is complete until the developer can explain it.** Claude acts as tutor and mock interviewer, in the chat, for every file and feature.

**Scope:** the full learning cycle below applies to executable code and its tests, including automation scripts. Routine repository setup, environment/ignore files, configuration, licenses, and Markdown documentation require a short purpose summary, file inventory, and relevant validation only; no separate learning guide, line-by-line review, exercise, or recruiter round. The developer still says "next" before the following task starts or the current task is committed. This exception also applies to the learning clauses in §14.5; code-related step recaps remain required.

**For every code file or feature built, in this order:**
1. **Preview:** before writing code, Claude states what will be built, why it exists, and where it sits in the request flow (§3).
2. **Build small:** one file or one tightly related group at a time, never a batch of unrelated files.
3. **Walkthrough:** after writing, Claude explains the file line by line in plain language, covering the Laravel concept used and the design reason (which SOLID principle, which blueprint rule).
4. **Developer review:** the developer reads the code and says what they do not understand. Claude re-explains until it is clear. Claude does not move on while questions are open.
5. **Recruiter round:** Claude plays a recruiter and asks 2 to 4 interview-style questions about that file (what it does, why it was designed this way, what breaks if changed, how to test it). The developer answers in their own words; Claude gives feedback and corrects gaps.
6. **Gate:** offer review after completing the small task. The developer may explicitly say "next" or ask to move on even with unanswered practice questions; respect that instruction, record remaining practice honestly, and proceed or commit. Never repeatedly block an explicit request to continue with more quiz questions.

**Rules:**
- Claude never silently adds code the developer has not been walked through.
- If the developer cannot answer a recruiter question, that file is revisited before continuing.
- Each roadmap step (§11) ends with a short recap quiz covering the whole step.
- The developer may ask "why" at any time; explaining takes priority over speed.
- Database work is explained too: for every migration and query, Claude shows the SQL it produces, why each index exists, and how to check it with `EXPLAIN`.
- `Laravel-Crash-Course.md` (desktop) is the reference for concepts; Claude links back to its sections when relevant.

### 1.7 Active code review practice (required for coding tasks)

The goal is independent reasoning: the developer must be able to read unfamiliar code, trace behavior, identify edge cases, and justify a fix without relying on the assistant to supply the answer.

- **Explanation style:** use the simplest possible language and concrete real-world examples. Introduce unfamiliar syntax before relying on it, and explain one small piece at a time.

- **File inventory:** report the exact number of new and modified files separately, with clickable paths, a one-sentence purpose for each, and a suggested reading order. Count tests and learning documents too; distinguish executable code from documentation and configuration.
- **Learning artifact:** maintain `docs/learning/<task-id>-<topic>.md` for each coding task. Include the inventory, actual implementation excerpts, line-by-line explanation, flow between files, validation results, and known limitations. Keep code examples small and tied to the current task.
- **Design reasoning:** explain why this implementation was chosen, the alternatives and tradeoffs, and the relevant Laravel concept and blueprint rule. Apply SOLID only where it genuinely applies.
- **Good and bad examples:** show a working approach beside a flawed alternative. Explain the concrete failure, its trigger, and the smallest correction. Label intentionally flawed examples as teaching-only; never add them to application code. For legal documents, preserve standard wording and use configuration or workflow examples instead of rewriting legal terms.
- **Independent review first:** include a separate, unannotated teaching snippet or diff with a deliberate defect. Ask the developer to predict behavior, trace inputs and outputs, identify edge cases, and suggest a fix or test before revealing the solution. Keep its answer out of the initial artifact; provide hints and feedback after the developer attempts it.
- **Interview practice:** the 2–4 recruiter questions must include reasoning about the actual code or configuration, a failure case, and how to verify behavior. Recall of terminology alone does not pass the review.
- **Small hands-on exercise:** ask the developer to make or propose one focused change and explain the expected result. Do not silently do their exercise for them.
- **Setup tasks:** provide a short purpose summary, file inventory, and relevant checks only, as specified in §1.6. Do not create learning guides or interview exercises for these tasks. Automation scripts are code and retain the full learning cycle.
- **Review after implementation:** finish implementation and validation, then provide a simple review with good practices. Keep unanswered exercises available for later. An explicit developer instruction to continue overrides the practice gate; record the override without claiming the questions were answered or mastery was demonstrated. Do not retroactively reopen tasks already accepted.

---

## 2. Features

### 2.1 MVP (build this first)
**Authentication & authorization**
- Register / login / logout via Sanctum (SPA cookie auth for the dashboard).
- Three roles: `admin`, `dispatcher`, `driver`. Policies enforce access per role.

**Shipment management** (admin, dispatcher)
- Create, view, update, cancel shipments.
- Fields: sender, recipient, addresses, parcel weight, notes, cash-on-delivery amount, priority.
- Auto-generated unique tracking number.
- Search and filter by status, date range, driver, tracking number; paginated.

**Driver management** (admin, dispatcher)
- Create and deactivate drivers, view driver workload.
- Assign / reassign a driver to a shipment.

**Delivery lifecycle**
- Status flow: `pending → assigned → picked_up → in_transit → delivered`, with branches to `failed` and `cancelled`.
- Invalid transitions are rejected by a state machine (see §6).
- Every transition writes an immutable entry to the shipment's event log (who, when, from, to, note).

**Driver view**
- Driver sees only their assigned shipments and can advance status or mark failed with a reason.

**Public tracking**
- Anyone with a tracking number can see current status and event timeline (no personal data exposed: no phone numbers, no full addresses).
- Rate-limited.

**Dashboard**
- Counts by status, deliveries per day (last 30 days), driver performance (delivered / failed ratio).

**Bilingual interface and SEO**
- Arabic and English are MVP requirements, built during frontend foundation and feature work (§2.4), rather than postponed to Phase 2.

### 2.2 Phase 2 (after MVP is solid)
- Proof of delivery (photo upload + recipient signature name).
- Email/SMS notification on status change via a pluggable `NotificationChannel`.
- Bulk import of shipments from CSV.
- Export reports to CSV.
- Audit log viewer for admins.

### 2.3 Explicitly out of scope
Real-time GPS, payments, route optimization, mobile apps. Mention them in the README as future work only.

### 2.4 Arabic / English and SEO (frontend roadmap)

**Translation choice:** use `i18next` with `react-i18next` for the Next.js interface. Do not substitute `next-intl` without the developer requesting a change. Implement this when frontend work begins; recording this requirement does not authorize skipping prerequisite roadmap tasks.

- Support `ar` and `en` through explicit locale routes such as `/ar` and `/en`. Validate locale values and define a documented default/fallback during task 8.6.
- Keep translated UI text in matching locale dictionaries, organized by feature or namespace. Avoid hardcoded visible text and language conditionals scattered through components.
- Load the chosen language on the server so the initial HTML already contains translated content. Keep server i18next instances isolated per request to prevent concurrent users receiving each other's language; hydrate client components consistently.
- Set HTML `lang` and `dir` from the locale: Arabic uses `rtl`, English uses `ltr`. Use CSS logical properties and verify forms, tables, icons, and mixed-language tracking numbers in both directions.
- Provide a language switcher that preserves the equivalent page when available, and use locale-aware formatting for dates, numbers, and money.
- Begin with one small translated page and switcher during task 8.6, with the usual code walkthrough and review, before applying the pattern to all features in task 9.6.
- This frontend requirement does not silently add backend localization packages. Decide Laravel validation/API message localization separately when those features are built.

**SEO from the frontend foundation:**
- Use Next.js metadata with translated titles and descriptions; eligible public pages have locale-specific canonical URLs and reciprocal `hreflang` alternates (`ar`/`en`). Generate absolute URLs from the configured public site origin, not a hardcoded production hostname.
- Add localized Open Graph metadata and suitable share metadata for eligible public pages. Use semantic HTML, meaningful headings, and translated image alternatives where applicable.
- Maintain `sitemap.xml` and `robots.txt` when public routes exist. Include only canonical, indexable public URLs in the sitemap; exclude login, authenticated dashboard, and shipment tracking pages/results.
- Preserve `noindex` for public shipment tracking pages, including localized metadata. Mark login and authenticated dashboard pages `noindex` too. These directives are not access control; policies and authentication still protect private data.
- Do not rely on robots.txt blocking to make crawlers read a page's `noindex`. Keep personal shipment data out of public metadata, share previews, and structured data.
- Test server-rendered translations, language switching, RTL/LTR, dictionary consistency, fallback/unsupported locales, metadata and alternate URLs, and the noindex/sitemap exclusions. Verify representative page HTML and complete an SEO audit during hardening.

---

## 3. Architecture

**Pattern:** layered architecture with Action classes (one use case per class).

```
HTTP Request
   → FormRequest (validation)
   → Controller (thin)
   → Action (use case, business logic)
   → Repository interface → Eloquent implementation
   → API Resource (response shaping)
```

- **Controllers** contain no business logic; max ~5 lines per method.
- **Actions** (`CreateShipment`, `AssignDriver`, `TransitionShipmentStatus`) hold business rules and are the unit-tested core.
- **DTOs** carry validated data from the request into Actions.
- **Repositories** wrap Eloquent queries that are non-trivial or reused; simple lookups may use the model directly through a repository method to keep Actions testable.
- **Events/Listeners** for side effects (log entry, notification) so Actions stay focused.
- **API Resources** shape every response; models are never returned directly.

---

## 4. Folder Structure

### 4.1 Backend (`backend/`)
```
backend/
├── app/
│   ├── Actions/
│   │   ├── Shipment/
│   │   │   ├── CreateShipment.php
│   │   │   ├── UpdateShipment.php
│   │   │   ├── CancelShipment.php
│   │   │   └── TransitionShipmentStatus.php
│   │   ├── Driver/
│   │   │   ├── CreateDriver.php
│   │   │   └── AssignDriverToShipment.php
│   │   └── Auth/
│   │       └── RegisterUser.php
│   ├── DTOs/
│   │   ├── CreateShipmentData.php
│   │   └── ShipmentFilterData.php
│   ├── Enums/
│   │   ├── ShipmentStatus.php
│   │   ├── UserRole.php
│   │   └── ShipmentPriority.php
│   ├── Events/
│   │   └── ShipmentStatusChanged.php
│   ├── Exceptions/
│   │   └── InvalidStatusTransition.php
│   ├── Http/
│   │   ├── Controllers/Api/V1/
│   │   │   ├── AuthController.php
│   │   │   ├── ShipmentController.php
│   │   │   ├── DriverController.php
│   │   │   ├── DriverShipmentController.php
│   │   │   ├── DashboardController.php
│   │   │   └── PublicTrackingController.php
│   │   ├── Middleware/
│   │   │   └── EnsureUserIsActive.php
│   │   ├── Requests/
│   │   │   ├── Auth/
│   │   │   └── Shipment/
│   │   └── Resources/
│   │       ├── ShipmentResource.php
│   │       ├── PublicTrackingResource.php
│   │       └── DriverResource.php
│   ├── Listeners/
│   │   └── RecordShipmentEvent.php
│   ├── Models/
│   │   ├── User.php
│   │   ├── Shipment.php
│   │   └── ShipmentEvent.php
│   ├── Policies/
│   │   └── ShipmentPolicy.php
│   ├── Providers/
│   │   └── RepositoryServiceProvider.php
│   ├── Repositories/
│   │   ├── Contracts/ShipmentRepository.php
│   │   └── EloquentShipmentRepository.php
│   └── Services/
│       ├── TrackingNumberGenerator.php
│       └── ShipmentStateMachine.php
├── database/
│   ├── factories/
│   ├── migrations/
│   └── seeders/
├── routes/
│   └── api.php
├── tests/
│   ├── Unit/
│   └── Feature/
├── phpstan.neon
├── pint.json
└── .env.example
```

### 4.2 Frontend (`frontend/`)
Feature-based structure; each feature owns its components, hooks, and API calls.
```
frontend/src/
├── i18n/                # i18next server/client setup, locale validation, dictionaries
├── app/                 # Next.js App Router: routes, layouts, providers
├── features/
│   ├── auth/            # LoginForm, useAuth, authApi
│   ├── shipments/       # ShipmentTable, ShipmentForm, useShipments, shipmentsApi
│   ├── drivers/
│   ├── dashboard/
│   └── tracking/        # public tracking page
├── components/ui/       # Button, Input, Modal, Table, StatusBadge
├── lib/                 # API client, formatters
├── hooks/               # shared hooks
└── types/               # shared TypeScript types
```

### 4.3 Repository root
```
.
├── backend/
├── frontend/
├── docker/
├── scripts/check-file-length.sh
├── .github/
│   ├── workflows/ci.yml
│   ├── dependabot.yml
│   └── PULL_REQUEST_TEMPLATE.md
├── docker-compose.yml
├── .gitignore
├── SECURITY.md
├── LICENSE
├── BLUEPRINT.md
└── README.md
```

---

## 5. Database Schema (MySQL)

All tables use `InnoDB`, `utf8mb4`, and foreign keys with explicit `ON DELETE` behavior.

**users**
| Column | Type | Notes |
|---|---|---|
| id | bigint PK | |
| name | varchar(120) | |
| email | varchar(190) | unique |
| password | varchar(255) | bcrypt/argon2 |
| role | enum(admin, dispatcher, driver) | indexed |
| phone | varchar(30) null | |
| is_active | boolean | default true |
| timestamps | | |

**shipments**
| Column | Type | Notes |
|---|---|---|
| id | bigint PK | |
| tracking_number | varchar(20) | unique |
| status | varchar(20) | indexed, backed by `ShipmentStatus` enum |
| priority | varchar(10) | |
| sender_name, sender_phone, sender_address | varchar | |
| recipient_name, recipient_phone, recipient_address | varchar | |
| weight_grams | unsigned int | |
| cod_amount | decimal(10,2) | default 0 |
| driver_id | FK users null | `nullOnDelete` |
| created_by | FK users | `restrictOnDelete` |
| delivered_at | timestamp null | |
| timestamps, softDeletes | | |

Indexes: `(status, created_at)`, `(driver_id, status)`, unique `tracking_number`.

**shipment_events** (append-only)
| Column | Type | Notes |
|---|---|---|
| id | bigint PK | |
| shipment_id | FK | `cascadeOnDelete` |
| from_status | varchar(20) null | |
| to_status | varchar(20) | |
| actor_id | FK users null | |
| note | varchar(500) null | |
| created_at | timestamp | no `updated_at`; rows are never edited |

Index: `(shipment_id, created_at)`.

---

## 6. Status State Machine

Allowed transitions, defined in one place (`ShipmentStateMachine`):

```
pending    → assigned, cancelled
assigned   → picked_up, pending (unassign), cancelled
picked_up  → in_transit, failed
in_transit → delivered, failed
failed     → assigned (retry)
delivered  → (terminal)
cancelled  → (terminal)
```

- Adding a status means adding one enum case and one map entry; no other code changes (Open/Closed).
- Drivers may only trigger `picked_up`, `in_transit`, `delivered`, `failed`. Dispatchers/admins handle the rest. Enforced in `ShipmentPolicy`.

---

## 7. API Design (`/api/v1`)

| Method | Endpoint | Access | Purpose |
|---|---|---|---|
| POST | /auth/login | public (throttled) | Log in |
| POST | /auth/logout | auth | Log out |
| GET | /auth/me | auth | Current user |
| GET | /shipments | admin, dispatcher | List with filters + pagination |
| POST | /shipments | admin, dispatcher | Create |
| GET | /shipments/{id} | admin, dispatcher | Detail with events |
| PATCH | /shipments/{id} | admin, dispatcher | Update |
| POST | /shipments/{id}/cancel | admin, dispatcher | Cancel |
| POST | /shipments/{id}/assign | admin, dispatcher | Assign driver |
| POST | /shipments/{id}/status | assigned driver, dispatcher | Transition status |
| GET | /driver/shipments | driver | My assigned shipments |
| GET | /drivers | admin, dispatcher | List drivers |
| POST | /drivers | admin | Create driver |
| GET | /dashboard/summary | admin, dispatcher | Stats |
| GET | /track/{trackingNumber} | public (throttled) | Public tracking timeline |

Conventions: consistent JSON envelope, `422` for validation, `403` for policy denials, `404` for missing resources, proper `409` for invalid status transitions. Auto-generate OpenAPI docs (e.g. with Scribe) and link them from the README.

---

## 8. Security (public repository)

### 8.1 Repository hygiene
- **Never commit secrets.** `.env` is git-ignored; only `.env.example` with dummy values is committed.
- Enable **GitHub secret scanning and push protection** on the repo before the first commit.
- Add a pre-commit hook running `gitleaks` locally.
- If a secret is ever committed, **rotate it immediately**; deleting the commit is not enough because history is public.
- Seeders create demo data only, with a clearly fake admin password documented as "local development only", and the seeder refuses to run when `APP_ENV=production`.
- Add `SECURITY.md` (how to report vulnerabilities) and a `LICENSE` (MIT is a reasonable default).
- Enable Dependabot and `composer audit` / `npm audit` in CI.

### 8.2 Application security
| Threat | Mitigation |
|---|---|
| SQL injection | Eloquent / query builder bindings only; no raw string concatenation. |
| Mass assignment | Explicit `$fillable`; DTOs instead of `$request->all()`. |
| Broken access control (IDOR) | Policy check on every shipment access; drivers scoped to their own shipments; tests cover cross-user access attempts. |
| Brute force | Login throttling (per email + IP); rate limits on public tracking. |
| Session / CSRF | Sanctum SPA cookie auth with CSRF protection, `SameSite=Lax`, secure cookies in production. |
| XSS | React escapes by default; never use `dangerouslySetInnerHTML`; strict CSP header. |
| Sensitive data exposure | Public tracking resource exposes status and timeline only; passwords hashed; logs never contain tokens or passwords. |
| Enumeration | Generic login error message; tracking numbers are non-sequential random strings (e.g. `DLV-` + 10 random alphanumerics), not auto-increment IDs. |
| Misconfiguration | `APP_DEBUG=false` in production; security headers (HSTS, X-Content-Type-Options, X-Frame-Options, Referrer-Policy); strict CORS allow-list. |
| Dependencies | Dependabot, lockfiles committed, CI audit step. |
| File uploads (Phase 2) | Validate MIME and size, store outside web root, random file names. |

### 8.3 Security tests
At least one feature test per row of the access-control matrix: each role attempting each endpoint it must **not** reach, expecting `403`.

---

## 9. Testing Strategy
- **Unit:** state machine, tracking number generator, DTO mapping, enums.
- **Feature:** every endpoint for success, validation failure, and unauthorized access, with `RefreshDatabase`.
- **Frontend:** Vitest + Testing Library for forms and key hooks; one Playwright smoke test (login → create shipment → assign → deliver) is a good Phase 2 addition.
- **CI blocks merge** on failing tests, Pint, PHPStan, ESLint, type-check, or the 150-line check.

---

## 10. CI/CD & DevOps
- `docker-compose.yml`: `app` (PHP-FPM), `nginx`, `mysql`, `frontend` (Next.js dev). One command to run locally: `docker compose up`.
- GitHub Actions `ci.yml`: install → lint → static analysis → tests (with MySQL service) → file-length check → frontend build.
- Continuous delivery pipeline and environments: see §14. Hosting candidates: backend on Render/Railway/DigitalOcean, frontend on Vercel; secrets only via the platform's environment settings.

---

## 11. Build Roadmap

| Step | Deliverable | Done when |
|---|---|---|
| 0 | Repo setup | Public repo, secret scanning on, `.gitignore`, LICENSE, SECURITY.md, CI skeleton, 150-line script |
| 1 | Backend skeleton | Laravel installed, Docker Compose works, Pint + PHPStan passing |
| 2 | Auth & roles | Login/logout, `UserRole` enum, policies, throttling, tests |
| 3 | Database | Migrations, factories, seeders (non-production only) |
| 4 | Shipments CRUD | Actions, DTOs, repository, resources, filters, tests |
| 5 | State machine & events | Transitions, event log, 409 on invalid transitions, tests |
| 6 | Drivers & assignment | Assign/reassign, driver-scoped endpoint, access tests |
| 7 | Public tracking | Safe resource, rate limiting, tests |
| 8 | Frontend foundation | Next.js + TS, auth flow (Sanctum cookies), route guards, API client, i18next + locale routing, SEO foundation |
| 9 | Frontend features | Shipment table/form, driver view, dashboard, tracking page, Arabic/English across features |
| 10 | Hardening | Security headers, CORS, audit pass, README with screenshots, API docs, bilingual and SEO audit |
| 11 | Phase 2 items | As time allows |
| 12 | Production deployment | `DEPLOYMENT.md` written and followed: hosting and environments, production `.env` and secrets, HTTPS, app/API on one parent domain for Sanctum cookies, safe migrations, queue worker and scheduler, backups, logging/monitoring, rollback |

Realistic timeline: steps 0–7 (working API) in about one week; 8–10 (dashboard and polish) in the second week.

---

## 12. README Checklist (what interviewers will open first)
- One-paragraph pitch and screenshot/GIF.
- Tech stack and architecture diagram.
- `docker compose up` quick start.
- Demo credentials (local only).
- API documentation link.
- Testing and CI badges.
- Design decisions: why Actions, why a state machine, why the 150-line rule.
- Security notes and known limitations.

---

## 13. Interview Preparation Notes
Be ready to explain, in your own words and with the code open:
- Why Actions instead of fat controllers or a generic service layer.
- How the state machine prevents invalid transitions and where the rules live.
- How a policy prevents one driver from reading another driver's shipment.
- The Eloquent relationships (`Shipment belongsTo User` as driver, `hasMany ShipmentEvent`) and the indexes you chose and why.
- How you would handle concurrency (two dispatchers assigning the same shipment): row locking or optimistic version check.
- What you would change to scale (queues for notifications, caching dashboard stats, read replicas).

---

## 14. Software Development Lifecycle

Every feature goes through the same loop. Nothing skips a stage.

| Stage | What happens here | Artifact |
|---|---|---|
| 1. Plan | Feature becomes a GitHub Issue with acceptance criteria; it maps to a task in `TASKS.md` | Issue + task |
| 2. Design | Non-obvious decisions get a short ADR (why this, not that) | `docs/adr/NNNN-title.md` |
| 3. Test first | Write a failing test for the behavior (red) | Test file |
| 4. Implement | Smallest code to pass (green), then clean up (refactor commit) | Code |
| 5. Local gate | Pint, PHPStan, ESLint, type-check, tests, 150-line check all pass locally | Clean run |
| 6. Pull request | Short-lived branch, Conventional Commit title, PR template filled in | PR |
| 7. CI | All checks must pass; branch protection blocks merge otherwise | Green build |
| 8. Review | Self-review of the diff, plus AI code review; findings resolved | Approved PR |
| 9. Merge | Squash-merge to `main`; `main` is always deployable | Commit on main |
| 10. Release | Tag semver (`v0.1.0`), generate changelog | Git tag + `CHANGELOG.md` |
| 11. Deploy | CD pipeline deploys to staging automatically, to production on manual approval | Live version |
| 12. Operate | Monitoring, logs, backups, dependency updates (Dependabot) | Dashboards, alerts |
| 13. Learn | Bugs get a regression test first, then a fix | Test + fix |

### 14.1 Test pyramid
- **Unit (many, fast, no database):** state machine, tracking number generator, DTOs, enums, Actions with a fake repository.
- **Feature (some):** every endpoint through HTTP with `RefreshDatabase`, plus the 403 access matrix.
- **End to end (few):** Playwright smoke test of the main flow, run against staging.
- **Rules:** tests are written before the code they cover; a bug fix starts with a test that reproduces it; CI fails below 80% coverage on the application layer.

### 14.2 CI (every push and PR)
Parallel jobs: backend (Pint, PHPStan, tests with MySQL service, coverage gate), frontend (ESLint, type-check, Vitest, build), security (`composer audit`, `npm audit`, gitleaks), and the 150-line check.

### 14.3 CD (on merge to `main`)
1. Build Docker images, tag with the commit SHA.
2. Deploy to **staging**, run migrations, run smoke tests.
3. Manual approval gate, then deploy to **production** (GitHub Environments with required reviewer).
4. Rollback = redeploy the previous image tag; migrations are written to be backward compatible for one release.

### 14.4 Branching and repo controls
- Branch protection on `main`: PR required, CI required, no force-push, linear history.
- Branch names: `feat/...`, `fix/...`, `refactor/...`.
- Environments: `local` (Docker), `staging`, `production`; each with its own secrets.

### 14.5 Definition of done (every task)
Tests written first and passing · all CI checks green · no file over 150 lines · walkthrough and recruiter round passed · docs updated (README, ADR, API docs if affected) · `TASKS.md` ticked.

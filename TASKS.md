# Task Tracker

Source of truth for progress. Steps match `BLUEPRINT.md` §11.
Updated after every "next" gate (see §1.6 of the blueprint).

**Legend:** `[ ]` todo · `[~]` in progress · `[x]` done (built, validated, applicable learning gate passed, committed)

**Coding cycle:** preview → build → walkthrough → developer review → recruiter round → "next" → commit.
**Setup/documentation cycle:** preview → build → short summary + validation → "next" → commit. No separate learning guide or interview exercises (blueprint §1.6).
**Per-step close:** recap quiz covering the whole step.
**Active review:** coding tasks follow `BLUEPRINT.md` §1.7: file inventory, flow, design tradeoffs, good/bad examples, an unanswered review exercise, and hands-on practice.
**Definition of done** (blueprint §14.5): tests first and green · CI green · no file over 150 lines · walkthrough and recruiter round passed · docs updated · this file ticked.

## Progress

| Step | Name | Status |
|---|---|---|
| 0 | Repo setup | 7 / 10 |
| 1 | Backend skeleton | 4 / 5 |
| 2 | Auth & roles | 2 / 6 |
| 3 | Database | 0 / 5 |
| 4 | Shipments CRUD | 0 / 8 |
| 5 | State machine & events | 0 / 5 |
| 6 | Drivers & assignment | 0 / 5 |
| 7 | Public tracking | 0 / 4 |
| 8 | Frontend foundation | 0 / 7 |
| 9 | Frontend features | 0 / 6 |
| 10 | Hardening | 0 / 6 |
| 11 | Phase 2 | 0 / 5 |
| 12 | Production deployment | 0 / 9 |

---

## Step 0: Repo setup
- [x] 0.1 Rename blueprint to `BLUEPRINT.md`, add this tracker, commit
- [x] 0.2 `.gitignore` — verification, learning review, recruiter round, and "next" gate passed
- [x] 0.3 `LICENSE` (MIT) — validated; developer accepted setup exception and "next" gate
- [x] 0.4 `SECURITY.md` — local checks passed; developer said "next"
- [x] 0.5 `scripts/check-file-length.sh` — tests passed; partial review completed; developer explicitly requested continuing with remaining practice deferred
  - [x] Counts code lines, ignores blank lines and supported comment forms (lexer limitations documented)
  - [x] Scans `app/`, `src/`, `routes/`, `tests/`; exemptions listed explicitly
  - [x] Fails with a clear message naming the file
- [~] 0.6 `.github/workflows/ci.yml` skeleton — developer approved and local commands passed; GitHub run pending after upload
- [x] 0.7 gitleaks pre-commit hook — installed and activated locally; unit and real clean/fake-secret commit checks passed; developer said "next"
- [~] 0.8 GitHub settings and PR/Dependabot files — developer approved local files; GitHub protections verified; activation after upload pending
  - [x] Secret scanning and push protection enabled (verified through GitHub API)
  - [x] Enable private vulnerability reporting for the SECURITY.md reporting channel (enabled and verified through GitHub API)
  - [x] Commit PR template and Dependabot config after developer review
  - [ ] Verify template availability and Dependabot activation after upload
- [~] 0.9 Branch protection, issue templates, and ADR template — protection verified; developer said "next"; template activation after upload pending
- [x] 0.10 `CHANGELOG.md` + semver tagging convention — developer accepted and requested starting Laravel; no release tag created
- [ ] Recap quiz

## Step 1: Backend skeleton
- [x] 1.1 Install Laravel 12 (PHP 8.3) in `backend/` — tests and dependency checks passed; developer accepted and said "next"; remaining exercises available for later
- [x] 1.2 `docker-compose.yml` + `docker/` (php-fpm, nginx, mysql) — stack running; Nginx, two Laravel tests, HTTP page, and real MySQL query passed; developer reviewed Docker ignore and said "continue"
- [x] 1.3 Pint config (`pint.json`) and passing run — PSR-12 configured; four scaffold files formatted; Pint check and two Laravel tests passed; developer said "next"
- [x] 1.4 PHPStan level 8 (`phpstan.neon`) and passing run — Larastan installed; level 8 passed without suppressed errors; removed always-passing scaffold test; developer reviewed Composer and requested the next task
- [~] 1.5 `.env.example` with dummy values; CI runs Pint + PHPStan — local isolated checks passed; developer accepted and requested continuing; first GitHub run pending upload
- [ ] Recap quiz

## Step 2: Auth & roles
- [x] 2.1 `UserRole` enum — checks passed; English walkthrough and review practice added; developer said "next" with exercises deferred
- [x] 2.2 Sanctum SPA setup (CSRF cookie, stateful domains, CORS allow-list) — checks passed; developer requested commit, push, and next; practice deferred
- [ ] 2.3 `RegisterUser` action + `AuthController` (login, logout, me)
- [ ] 2.4 Login throttling (per email + IP), generic error message
- [ ] 2.5 `EnsureUserIsActive` middleware
- [ ] 2.6 Feature tests: login, logout, throttling, inactive user
- [ ] Recap quiz

## Step 3: Database
- [ ] 3.1 `users` migration (role, phone, is_active)
- [ ] 3.2 `shipments` migration (indexes, FKs, soft deletes)
- [ ] 3.3 `shipment_events` migration (append-only)
- [ ] 3.4 Models + relationships + `$fillable`, factories
- [ ] 3.5 Seeders (demo data, refuses to run in production)
- [ ] Recap quiz (includes `EXPLAIN` on the main indexes)

## Step 4: Shipments CRUD
- [ ] 4.1 `ShipmentStatus` + `ShipmentPriority` enums
- [ ] 4.2 `TrackingNumberGenerator` service + unit test
- [ ] 4.3 `ShipmentRepository` contract + Eloquent implementation + provider binding
- [ ] 4.4 DTOs (`CreateShipmentData`, `ShipmentFilterData`)
- [ ] 4.5 `CreateShipment`, `UpdateShipment`, `CancelShipment` actions
- [ ] 4.6 FormRequests, `ShipmentResource`, `ShipmentController`
- [ ] 4.7 `ShipmentPolicy` + search/filter/pagination
- [ ] 4.8 Feature tests: success, validation, 403 matrix
- [ ] Recap quiz

## Step 5: State machine & events
- [ ] 5.1 `ShipmentStateMachine` (transition map) + unit tests
- [ ] 5.2 `InvalidStatusTransition` exception → 409
- [ ] 5.3 `TransitionShipmentStatus` action
- [ ] 5.4 `ShipmentStatusChanged` event + `RecordShipmentEvent` listener
- [ ] 5.5 Feature tests: valid/invalid transitions, event log rows
- [ ] Recap quiz

## Step 6: Drivers & assignment
- [ ] 6.1 `CreateDriver` action + `DriverController` + `DriverResource`
- [ ] 6.2 `AssignDriverToShipment` action (assign / reassign / unassign)
- [ ] 6.3 `DriverShipmentController` (driver sees only own shipments)
- [ ] 6.4 Concurrency guard for double assignment (row lock)
- [ ] 6.5 Access tests: cross-driver IDOR attempts
- [ ] Recap quiz

## Step 7: Public tracking
- [ ] 7.1 `PublicTrackingResource` (no personal data)
- [ ] 7.2 `PublicTrackingController` + route
- [ ] 7.3 Rate limiting
- [ ] 7.4 Tests: unknown number, data exposure, throttling
- [ ] Recap quiz

## Step 8: Frontend foundation
- [ ] 8.1 Next.js (App Router) + TypeScript strict, ESLint + Prettier
- [ ] 8.2 API client (`lib/`) with CSRF cookie handling
- [ ] 8.3 Auth feature: `LoginForm`, `useAuth`, `authApi`
- [ ] 8.4 Route guards by role
- [ ] 8.5 Vitest + Testing Library setup, CI frontend build/lint/type-check
- [ ] 8.6 i18next + react-i18next Arabic/English foundation (BLUEPRINT.md §2.4)
  - [ ] Locale dictionaries, server-rendered translations, request-isolated instances, consistent client hydration
  - [ ] `/ar` and `/en` routes; locale validation; document default and fallback
  - [ ] Small translated page and language switcher preserving the equivalent route
  - [ ] HTML lang + RTL/LTR; locale-aware date/number/currency formatting
  - [ ] Tests for switching, fallback, unsupported locales, dictionary consistency, and request isolation
- [ ] 8.7 SEO foundation (BLUEPRINT.md §2.4)
  - [ ] Translated Next.js titles/descriptions; locale-specific canonical and reciprocal hreflang URLs
  - [ ] Public-page share metadata and configured absolute site URLs
  - [ ] Sitemap and robots policy; login, dashboard, and shipment tracking noindex/exclusions
  - [ ] Verify rendered HTML and metadata for both languages; no personal data in metadata
- [ ] Recap quiz

## Step 9: Frontend features
- [ ] 9.1 UI primitives (`Button`, `Input`, `Modal`, `Table`, `StatusBadge`)
- [ ] 9.2 Shipments: table, filters, form
- [ ] 9.3 Driver view: assigned shipments, status updates
- [ ] 9.4 Dashboard: counts, deliveries/day, driver performance (+ `DashboardController`)
- [ ] 9.5 Public tracking page (server-rendered, `noindex`)
- [ ] 9.6 Apply Arabic/English translations and RTL/LTR to all frontend features
  - [ ] Auth, shipments, drivers, dashboard, and tracking text and validation feedback
  - [ ] Review forms/tables and mixed-language identifiers in both directions
  - [ ] Verify localized metadata and noindex on tracking pages
- [ ] Recap quiz

## Step 10: Hardening
- [ ] 10.1 Security headers + CSP
- [ ] 10.2 CORS + cookie settings audit
- [ ] 10.3 Security audit pass (blueprint §8.2 table, row by row)
- [ ] 10.4 API docs (Scribe)
- [ ] 10.5 README (checklist in blueprint §12), screenshots
- [ ] 10.6 Bilingual + SEO audit: rendered translations, locale URLs, canonical/hreflang, share metadata, sitemap/robots, noindex exclusions, semantic HTML, and performance
- [ ] Recap quiz

## Step 11: Phase 2 (as time allows)
- [ ] 11.1 Proof of delivery
- [ ] 11.2 Notifications via `NotificationChannel`
- [ ] 11.3 CSV bulk import
- [ ] 11.4 CSV export
- [ ] 11.5 Audit log viewer

Arabic/English with RTL (formerly 11.6) is now part of MVP tasks 8.6, 9.6, and 10.6; SEO starts at 8.7. Implement these when their roadmap steps are reached.

## Step 12: Production deployment
- [ ] 12.1 Write `DEPLOYMENT.md` (hosting choice, environments, cost)
- [ ] 12.2 Production `.env` and secrets handling
- [ ] 12.3 Domains + HTTPS (app and API on one parent domain for Sanctum cookies)
- [ ] 12.4 Safe migrations, queue worker, scheduler
- [ ] 12.5 Backups and restore test
- [ ] 12.6 Logging and monitoring
- [ ] 12.7 Rollback plan + go-live checklist
- [ ] 12.8 CD pipeline: build images, auto-deploy to staging, smoke tests, manual approval to production (GitHub Environments)
- [ ] 12.9 Playwright smoke test against staging (login → create → assign → deliver), first tagged release `v1.0.0`

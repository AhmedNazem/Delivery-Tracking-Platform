# Releases and version tags

## Version convention

Use Semantic Versioning with Git tags formatted `vMAJOR.MINOR.PATCH`:

- MAJOR: incompatible changes to the documented public API once stable.
- MINOR: backward-compatible functionality.
- PATCH: backward-compatible fixes.

Example after a stable release: `v1.2.3` → `v1.2.4` for a fix,
`v1.3.0` for a compatible feature, or `v2.0.0` for an incompatible API change.

The `0.x` series is initial development: compatibility is not guaranteed. Record
breaking changes explicitly rather than implying stable compatibility. The first
approved development release may be `v0.1.0`; `v1.0.0` is reserved for the MVP
with a documented stable API and the production readiness checks in task 12.
Use `v0.1.0-rc.1` if a release candidate is needed.

See the [Semantic Versioning specification](https://semver.org/).

## Changelog convention

Keep new entries under `Unreleased`. Use sections such as Added, Changed, Fixed,
Removed, and Security where relevant. Describe behavior and impact, not every
commit. Distinguish planned features from implemented features and local work
from deployed work.

When a release is approved, move its entries into a section such as
`## [0.1.0] - YYYY-MM-DD`, using the actual release date. Keep an empty Unreleased
section for subsequent work. Do not use a planned date as an actual release date.

## Release procedure

1. Select the scope and version, update CHANGELOG.md, and review via a PR.
2. Run applicable local checks and require passing CI and review before merging.
3. On the merged `main` commit, create an annotated tag only after release approval.
4. Verify the tag points to the intended commit, then publish it and the release
   notes only when publishing has been authorized.
5. Follow the staging/production approval and rollback process in blueprint §14.3.

Example commands after an approved release (not executed for task 0.10):

```bash
git switch main
git pull --ff-only
git tag -a v0.1.0 -m "Release v0.1.0"
git show --no-patch v0.1.0
git push origin v0.1.0
```

Published tags are immutable: do not move or force-push them. Fix a published
release with a new version. A release tag records a version; it does not itself
prove deployment succeeded. No release tag is created merely to finish setup.

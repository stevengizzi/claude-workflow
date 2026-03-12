# Versioning Policy

## Scheme

This repo uses semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes to protocol structure, schema changes that require
  runner updates, or changes to close-out/verdict JSON formats.
- **MINOR**: New protocols, new templates, new rules, runner features that are
  backward compatible.
- **PATCH**: Clarifications, typo fixes, documentation improvements, bug fixes
  in runner code.

## Version Headers

Every protocol and template file includes a version header:
```
<!-- workflow-version: 1.0.0 -->
<!-- last-updated: 2026-03-12 -->
```

These are informational for Claude.ai conversations. When fetching a protocol,
Claude notes the version. If a protocol changes mid-sprint, the sprint continues
with the version used at planning time.

## Tagging

Releases are tagged in git: `v1.0.0`, `v1.1.0`, etc.

Projects can pin to a specific version:
```bash
cd workflow
git checkout v1.2.0
cd ..
git add workflow
git commit -m "Pin workflow to v1.2.0"
```

Or track `main` for latest:
```bash
cd workflow
git pull origin main
cd ..
git add workflow
git commit -m "Update workflow to latest"
```

## Upgrade Path

1. Run `sync.sh` to see current state
2. Review the changelog for the target version
3. Update submodule: `cd workflow && git pull origin main`
4. Re-run `setup.sh` to update symlinks
5. Run `sync.sh` again to verify clean state
6. If runner schemas changed (MAJOR bump): update any cached runner configs

## Current Version

**v1.0.0** — Initial extraction from ARGUS (March 2026)

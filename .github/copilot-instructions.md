<!-- file: .github/copilot-instructions.md -->
<!-- version: 2.4.0 -->
<!-- guid: 4d5e6f7a-8b9c-0d1e-2f3a-4b5c6d7e8f9a -->
<!-- last-edited: 2026-06-13 -->

# gha-release-strategy — Additional Context

Org-wide coding standards (file headers, language rules, commit format) are at
**<https://github.com/falkcorp/.github>** and apply automatically to this repo.

For full project context: **CLAUDE.md** at the repo root.

## Project overview

GHA composite action: release strategy and versioning decisions. Language: Shell/YAML.
The main entry point is `action.yml` (composite action definition) and `src/release_strategy.sh`.

## Key directories

| Directory | Purpose |
|-----------|---------|
| `src/` | Shell scripts implementing the release strategy logic |
| `action.yml` | Composite action definition (inputs, outputs, steps) |
| `template/` | Template files for release artifacts |

# Release Strategy & Changelog Action

Comprehensive release automation action that determines release strategy, generates changelogs, and builds release summaries. This action consolidates three separate workflow helper scripts into a single composite action.

## Features

✅ **Release Strategy Determination** - Analyze branch and configuration to determine if release should be stable/prerelease/draft
✅ **Changelog Generation** - Automatically generate release notes from git commit history
✅ **Release Summary Building** - Create formatted summary of release components and results
✅ **Branch-Aware Logic** - Different behavior for `main`, `develop`, and feature branches
✅ **Override Controls** - Force specific release types when needed
✅ **Embedded Python/Bash** - No external dependencies needed (composite action)

## Usage

### Basic: Determine Release Strategy

```yaml
- name: Determine release strategy
  id: strategy
  uses: jdfalk/release-strategy-action@v2
  with:
    branch-name: ${{ github.ref_name }}

- name: Create release
  uses: softprops/action-gh-release@v1
  with:
    draft: ${{ steps.strategy.outputs.is-draft }}
    prerelease: ${{ steps.strategy.outputs.is-prerelease }}
    tag_name: v1.2.3
```

### Generate Changelog

```yaml
- name: Generate changelog
  id: changelog
  uses: jdfalk/release-strategy-action@v2
  with:
    branch-name: ${{ github.ref_name }}
    command: "changelog"
    primary-language: "go"
    release-strategy: "stable"

- name: Create release with changelog
  uses: softprops/action-gh-release@v1
  with:
    tag_name: v1.2.3
    body: ${{ steps.changelog.outputs.changelog }}
```

### Generate Release Summary

```yaml
- name: Build release summary
  uses: jdfalk/release-strategy-action@v2
  with:
    branch-name: ${{ github.ref_name }}
    command: "summary"
    primary-language: "multi"
    release-tag: ${{ env.RELEASE_TAG }}
    release-strategy: "stable"
    build-target: "go,python"
    summary-components: '{"Go": "success", "Python": "success", "Docker": "skipped"}'
```

## Inputs

| Input                | Description                                                  | Required | Default    |
| -------------------- | ------------------------------------------------------------ | -------- | ---------- |
| `branch-name`        | Git branch name (usually `github.ref_name`)                  | Yes      | -          |
| `command`            | Command to execute: `strategy`, `changelog`, or `summary`    | No       | `strategy` |
| `force-prerelease`   | Force release as prerelease regardless of branch             | No       | `false`    |
| `force-draft`        | Force release as draft regardless of branch                  | No       | `false`    |
| `primary-language`   | Primary language of the project (for `changelog`/`summary`)  | No       | `unknown`  |
| `release-tag`        | Release tag for summary display                              | No       | `n/a`      |
| `release-strategy`   | Release strategy for summary display                         | No       | `n/a`      |
| `build-target`       | Build target for summary display                             | No       | `all`      |
| `summary-components` | JSON string of component results (e.g., `{"Go": "success"}`) | No       | `{}`       |

## Outputs

### Strategy command

| Output            | Description                                           |
| ----------------- | ----------------------------------------------------- |
| `strategy`        | Release strategy: `stable`, `prerelease`, or `draft`  |
| `auto-prerelease` | Whether to auto-mark as prerelease: `true` or `false` |
| `auto-draft`      | Whether to auto-mark as draft: `true` or `false`      |
| `is-stable`       | Is this a stable release: `true` or `false`           |
| `is-prerelease`   | Is this a prerelease: `true` or `false`               |
| `is-draft`        | Is this a draft release: `true` or `false`            |

### Changelog command

| Output      | Description                                    |
| ----------- | ---------------------------------------------- |
| `changelog` | Generated changelog content in Markdown format |

### Summary command

No direct outputs (appends to GitHub step summary)

## Release Strategy Logic

### Branch-Based Behavior

| Branch      | Strategy   | Details                                           |
| ----------- | ---------- | ------------------------------------------------- |
| `main`      | Stable     | Created as **DRAFT** for review before publishing |
| `develop`   | Prerelease | Published **DIRECTLY** as prerelease              |
| `feature/*` | Prerelease | Published **DIRECTLY** as prerelease              |
| Any other   | Prerelease | Treated as feature branch                         |

### Overrides

Force a specific strategy regardless of branch:

```yaml
with:
  branch-name: main
  force-prerelease: true  # Override main → prerelease
```

## Changelog Generation

The `changelog` command generates release notes containing:

- **Commits List**: All commits since the last git tag
- **Release Information**: Branch, strategy, and language metadata
- **Status Badges**: Indicates if prerelease or draft

Example generated changelog:
```markdown
## 🚀 What's Changed

### 📋 Commits since v1.2.3:
- feat(api): Add new endpoint (abc123)
- fix(core): Resolve memory leak (def456)

### 🎯 Release Information
- **Branch:** main
- **Release Type:** stable
- **Primary Language:** go

📝 **This is a draft release** - review before making public.
```

## Summary Generation

The `summary` command creates a structured release summary displaying:

- Project type and build target
- Component build results (success/failure/skipped)
- Release tag and strategy
- Overall status with emoji indicators

Example summary output:
```markdown
# 🚀 Release Build Results

**Project Type:** go
**Build Target:** all
**Release Tag:** v1.2.3
**Release Strategy:** stable
**Branch:** main

| Component | Status  |
| --------- | ------- |
| Go        | success |
| Python    | skipped |
| Docker    | success |

🎉 **Release created: v1.2.3**
📝 **Draft release** - review before publishing
✅ **All components completed successfully**
```

## Comparison with Previous Version

### v1.0.0 (Original)
- Single command: determine release strategy only
- Called external bash script `src/release_strategy.sh`
- Limited to strategy determination

### v2.0.0 (Enhanced)
- **Three commands**: strategy, changelog, summary
- **Embedded Python**: All logic embedded in action.yml (no external scripts)
- **Consolidated Scripts**: Merges logic from:
  - `release_workflow.py` (strategy determination)
  - `generate_release_summary.py` (summary building)
  - `generate-changelog.sh` (changelog generation)
- **Extended Outputs**: New changelog and summary capabilities
- **Backward Compatible**: Default command remains `strategy` for existing workflows

## Examples

### Workflow: Full Release Pipeline

```yaml
name: Release

on:
  push:
    branches: [main, develop]
    tags: [v*]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Determine strategy
        id: strategy
        uses: jdfalk/release-strategy-action@v2
        with:
          branch-name: ${{ github.ref_name }}

      - name: Generate changelog
        id: changelog
        uses: jdfalk/release-strategy-action@v2
        with:
          branch-name: ${{ github.ref_name }}
          command: "changelog"
          primary-language: "go"
          release-strategy: ${{ steps.strategy.outputs.strategy }}

      - name: Create release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            dist/**/*
          draft: ${{ steps.strategy.outputs.is-draft }}
          prerelease: ${{ steps.strategy.outputs.is-prerelease }}
          body: ${{ steps.changelog.outputs.changelog }}
```

### Workflow: Multi-Component Release with Summary

```yaml
- name: Build summary
  if: always()
  uses: jdfalk/release-strategy-action@v2
  with:
    branch-name: ${{ github.ref_name }}
    command: "summary"
    primary-language: "multi"
    release-tag: ${{ env.RELEASE_TAG }}
    release-strategy: "stable"
    build-target: "go,python,docker"
    summary-components: |
      {
        "Go": "${{ job.go.result }}",
        "Python": "${{ job.python.result }}",
        "Docker": "${{ job.docker.result }}"
      }
```

## Migration Guide (v1 → v2)

Existing workflows using v1.0.0 will continue to work without changes. The `strategy` command is the default:

**v1.0.0 (still works):**
```yaml
- uses: jdfalk/release-strategy-action@v1
  id: strategy
  with:
    branch-name: ${{ github.ref_name }}
```

**v2.0.0 (updated, recommended):**
```yaml
- uses: jdfalk/release-strategy-action@v2
  id: strategy
  with:
    branch-name: ${{ github.ref_name }}
    command: "strategy"  # Optional (default)
```

To use new changelog/summary features, explicitly set the `command` input.

## Related Actions

- [ci-workflow-helpers-action](https://github.com/jdfalk/ci-workflow-helpers-action) - Multi-language CI helpers
- [release-go-action](https://github.com/jdfalk/release-go-action) - Go-specific release automation
- [release-python-action](https://github.com/jdfalk/release-python-action) - Python-specific release automation

## License

MIT

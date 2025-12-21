# Release Strategy Action

Determine release strategy (stable/prerelease/draft) based on git branch and configuration.

## Usage

```yaml
- name: Determine release strategy
  id: strategy
  uses: jdfalk/release-strategy-action@v1
  with:
    branch-name: ${{ github.ref_name }}
    force-prerelease: false
    force-draft: false

- name: Create release
  uses: softprops/action-gh-release@v1
  with:
    draft: ${{ steps.strategy.outputs.is-draft }}
    prerelease: ${{ steps.strategy.outputs.is-prerelease }}
    tag_name: v1.2.3
```

## Inputs

| Input              | Description                 | Required |
| ------------------ | --------------------------- | -------- |
| `branch-name`      | Git branch name             | Yes      |
| `force-prerelease` | Force release as prerelease | No       |
| `force-draft`      | Force release as draft      | No       |

## Outputs

| Output            | Description                                      |
| ----------------- | ------------------------------------------------ |
| `strategy`        | Release strategy (`stable`/`prerelease`/`draft`) |
| `auto-prerelease` | Whether to auto-mark as prerelease               |
| `auto-draft`      | Whether to auto-mark as draft                    |
| `is-stable`       | Whether this is stable (`true`/`false`)          |
| `is-prerelease`   | Whether this is prerelease                       |
| `is-draft`        | Whether this is draft                            |

## Strategy Logic

### Branch-Based Strategy

| Branch      | Strategy   | Details                                           |
| ----------- | ---------- | ------------------------------------------------- |
| `main`      | Stable     | Created as **DRAFT** for review before publishing |
| `develop`   | Prerelease | Published **DIRECTLY** as prerelease              |
| `feature/*` | Prerelease | Published **DIRECTLY** as prerelease              |

### Overrides

Force a specific strategy regardless of branch:

```yaml
with:
  branch-name: main
  force-prerelease: true  # Override main → prerelease
```

## Examples

### Workflow: Release from main (stable)
```yaml
- uses: jdfalk/release-strategy-action@v1
  id: strategy
  with:
    branch-name: main

# Output:
# strategy=stable
# is-draft=true
# auto-draft=true
```

### Workflow: Release from develop (prerelease)
```yaml
- uses: jdfalk/release-strategy-action@v1
  id: strategy
  with:
    branch-name: develop

# Output:
# strategy=prerelease
# is-prerelease=true
# auto-prerelease=true
```

## Features

✅ **Branch-Aware** - Different strategy per branch
✅ **Override Control** - Force specific strategy
✅ **Draft Support** - Main releases start as drafts
✅ **Clear Output** - Boolean flags for easy conditionals
✅ **Transparent Logic** - Documented decision flow

## Related Actions

- [generate-version-action](https://github.com/jdfalk/generate-version-action) - Generate semantic versions
- [detect-languages-action](https://github.com/jdfalk/detect-languages-action) - Detect project languages

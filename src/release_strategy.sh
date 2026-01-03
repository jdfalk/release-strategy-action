#!/bin/bash
# file: src/release_strategy.sh
# version: 1.0.1
# guid: 7a8b9c0d-1e2f-3a4b-5c6d-7e8f9a0b1c2d

set -euo pipefail

# Determine release strategy based on branch
branch="${BRANCH_NAME}"
force_prerelease_env="${FORCE_PRERELEASE:-}"
force_draft_env="${FORCE_DRAFT:-}"
force_prerelease="${force_prerelease_env,,}"
force_draft="${force_draft_env,,}"

# Default flags
auto_prerelease="false"
auto_draft="false"
strategy="stable"

# Strategy logic
if [[ $force_prerelease == "true" ]]; then
  strategy="prerelease"
elif [[ $force_draft == "true" ]]; then
  strategy="draft"
elif [[ $branch == "main" ]]; then
  strategy="stable"
  auto_draft="true" # Main releases start as drafts for review
elif [[ $branch == "develop" ]]; then
  strategy="prerelease"
  auto_prerelease="true"
else
  # Feature branches = prerelease
  strategy="prerelease"
  auto_prerelease="true"
fi

# Set boolean flags
is_stable="false"
is_prerelease="false"
is_draft="false"

case "$strategy" in
stable)
  is_stable="true"
  ;;
prerelease)
  is_prerelease="true"
  ;;
draft)
  is_draft="true"
  ;;
esac

# Write outputs
{
  echo "strategy=$strategy"
  echo "auto-prerelease=$auto_prerelease"
  echo "auto-draft=$auto_draft"
  echo "is-stable=$is_stable"
  echo "is-prerelease=$is_prerelease"
  echo "is-draft=$is_draft"
} >>"$GITHUB_OUTPUT"

# Summary
{
  echo "## 📦 Release Strategy"
  echo "- **Branch:** \`$branch\`"
  echo "- **Strategy:** \`$strategy\`"
  echo "- **Auto-prerelease:** $auto_prerelease"
  echo "- **Auto-draft:** $auto_draft"
  echo ""
  echo "### Strategy Logic"
  # shellcheck disable=SC2016
  echo '- `main` branch → Stable release (created as DRAFT for review)'
  # shellcheck disable=SC2016
  echo '- `develop` branch → Pre-release (published DIRECTLY)'
  echo "- Feature branches → Pre-release (published DIRECTLY)"
} >>"$GITHUB_STEP_SUMMARY"

echo "✅ Release strategy determined: $strategy"

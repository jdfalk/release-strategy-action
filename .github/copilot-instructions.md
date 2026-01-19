<!-- file: .github/copilot-instructions.md -->
<!-- version: 1.1.0 -->
<!-- guid: a3b4c5d6-e7f8-9012-a890-123456789012 -->
<!-- last-edited: 2026-01-19 -->

# AI Agent Instructions (Standard)

- Use VS Code tasks for non-git operations; prefer MCP GitHub tools for git operations.
- Commits must use conventional commits (type(scope): description).
- Include versioned headers in docs/configs and bump versions on changes.
- This is a composite GitHub Action that embeds Python logic directly in action.yml.
- All changes to release strategy logic should be made in the embedded Python script within action.yml.
- Follow GitHub Actions composite action best practices.
- Provide concise plans and progress updates.

## 🎯 Communication Protocol

**Error Response Policy**: When errors occur or corrections are needed, skip apologies and respond with "Aye Aye Captain" followed immediately by the corrected solution. Time efficiency is critical—acknowledge, correct, and move forward without unnecessary preamble.

## 📁 File Organization Conventions

**Repository Structure**:

- All files require versioned headers: `<!-- file: path -->`, `<!-- version: x.y.z -->`, `<!-- guid: uuid -->`, `<!-- last-edited: YYYY-MM-DD -->`
- Always increment version numbers on file changes (patch/minor/major semantic versioning)
- Update `last-edited` date whenever making changes

## 🔧 Critical AI Agent Workflows

Use VS Code tasks for non-git operations (build, lint, generate). For git operations, prefer:

1. MCP GitHub tools (preferred), 2) safe-ai-util (fallback), 3) native git (last resort).

### Git Operations (Policy)

- Prefer MCP GitHub tools or safe-ai-util for all git actions (add/commit/push).
- Avoid VS Code git tasks; keep git automation out of editor tasks.
- All commits MUST use conventional commit format: `type(scope): description`.
- See `.github/instructions/commit-messages.instructions.md` for detailed commit message rules.

### Terminal Command Length Limits (CRITICAL)

**MANDATORY RULE: Long terminal commands WILL fail and die.**

Terminal commands with excessive length (either many arguments or very long single lines) will fail with exit code 130 or similar errors. Follow these rules:

**Maximum Safe Limits:**

- **For loops with paths**: No more than 5 paths/arguments
- **Single-line commands**: No more than ~200-300 characters
- **Multi-argument commands**: No more than 5-6 distinct arguments

**Example of TOO LONG (will fail):**

```bash
for pr_dir in /path/one /path/two /path/three /path/four /path/five /path/six /path/seven /path/eight /path/nine /path/ten; do ...
```

**Solution: Use a script in temp_crap repo:**

```bash
# Instead, create a script
cat > /Users/jdfalk/repos/temp_crap/my_script.sh << 'EOF'
#!/bin/bash
for pr_dir in /path/one /path/two /path/three ... /path/twenty; do
    # Command logic here
done
EOF
chmod +x /Users/jdfalk/repos/temp_crap/my_script.sh
/Users/jdfalk/repos/temp_crap/my_script.sh
```

**Why temp_crap:**

- Always available in the workspace
- No approval needed for file creation
- Can handle unlimited command complexity
- Python scripts preferred for anything beyond simple bash

**If you exceed these limits, you WILL break the terminal execution.**

## Repository Context

This repository provides a composite GitHub Action that determines release strategies based on conventional commits and repository configuration.

**Key Files:**

- [action.yml](action.yml) - Main composite action with embedded Python script
- [README.md](README.md) - Comprehensive documentation and examples
- [CHANGELOG.md](CHANGELOG.md) - Version history

**Design Pattern:**

- Composite action using `shell: python` to embed the entire Python script
- Single file action.yml contains all logic (no separate src/ directory needed)
- All environment variables passed as action inputs
- Outputs exposed via GitHub Actions output commands

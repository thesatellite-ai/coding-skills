---
name: feature-plan
description: Plan and track features across repos. Creates feature docs, GitHub issues with subtasks, and maintains a feature index. Use when planning a new feature, adding subtasks, logging commits, or listing features.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh *), Bash(git log*), Bash(git rev-parse*), Bash(date*), Bash(mkdir*)
argument-hint: "Feature Name" | task FT-XXX "Task Name" | log FT-XXX [commit] | status FT-XXX | list
---

# Feature Planning Skill

You manage a feature tracking system that links docs, GitHub issues, subtasks, and commits across repos.

## Config

Look for `.featurerc.yml` in the project root. If it doesn't exist, ask the user to create one first using this template:

```yaml
# Feature tracking configuration
# -----------------------------------------------

# Project identifier — used as prefix: PROJECT-001, PROJECT-002
# Keep it short (2-4 chars), uppercase
prefix: FT

# GitHub repositories linked to this project
# Issues are created in each repo when a new feature is planned
repos:
  # - owner/repo-name
  - acme/backend
  - acme/frontend

# Default labels applied to GitHub issues
labels:
  - feature

# Feature docs location (relative to project root)
docs_dir: docs/features
```

Read `.featurerc.yml` and parse it. All fields are required except `labels` (defaults to `["feature"]`).

## Commands

Parse `$ARGUMENTS` to determine the command:

### 1. New Feature: `$ARGUMENTS` is a feature name string (no keyword prefix)

Example: `/feature-plan User Authentication`

Steps:
1. Read `.featurerc.yml` for config
2. Read `{docs_dir}/INDEX.md` to find the last used ID number (or start at 001 if INDEX.md doesn't exist)
3. Increment to get next ID: `{prefix}-{NNN}` zero-padded to 3 digits
4. Create the feature directory: `{docs_dir}/{ID}-{slug}/`
5. Create the feature doc at `{docs_dir}/{ID}-{slug}/README.md` using the Feature Doc Template
6. Create a GitHub issue in EACH repo from config using `gh issue create`:
   - Title: `[{ID}] {Feature Name}`
   - Body: link back to the feature doc path and cross-reference the other repo's issue
   - Labels: from config
7. Update the feature doc with the created issue URLs
8. Append entry to `{docs_dir}/INDEX.md`
9. Print summary with the feature ID, doc path, issue URLs, and commit convention

### 2. Add Subtask: `$ARGUMENTS` starts with "task"

Example: `/feature-plan task FT-001 "Setup OAuth provider"`

This creates a subtask (sub-issue) under a feature. Subtasks are numbered sequentially within the feature: `{ID}.1`, `{ID}.2`, etc.

Steps:
1. Read `.featurerc.yml` for config
2. Parse the feature ID and task name from args
3. Find the feature directory by globbing `{docs_dir}/{ID}-*/`
4. Read the feature README.md to find the last subtask number (or start at 1)
5. Create a subtask doc at `{docs_dir}/{ID}-{slug}/tasks/{ID}.{N}-{task-slug}.md` using the Subtask Template
6. Create a GitHub issue in the appropriate repo(s) using `gh issue create`:
   - Title: `[{ID}.{N}] {Task Name}`
   - Body: references the parent feature issue and doc
   - Labels: from config + `subtask`
   - Ask the user which repo(s) if ambiguous, or create in all repos if the task spans both
7. Update the subtask doc with the created issue URL(s)
8. Append the subtask to the Subtasks table in the feature README.md
9. Print confirmation with subtask ID and issue URLs

### 3. Log Commit: `$ARGUMENTS` starts with "log"

Example: `/feature-plan log FT-001 abc1234` or `/feature-plan log FT-001` (auto-detect latest commit)
Example with subtask: `/feature-plan log FT-001.2 abc1234`

Steps:
1. Parse the feature ID (and optional subtask number) and optional commit hash from args
2. If no commit hash, use `git rev-parse HEAD` to get the latest
3. Get commit message and date via `git log`
4. Determine repo name from git remote
5. Find the feature directory by globbing `{docs_dir}/{ID}-*/`
6. Append a row to the Commit Log table in the feature README.md
7. If a subtask number is specified (e.g., FT-001.2), also append to that subtask's doc
8. Print confirmation

### 4. Status: `$ARGUMENTS` starts with "status"

Example: `/feature-plan status FT-001`

Steps:
1. Find and read the feature README.md
2. Read all subtask docs from the tasks/ subdirectory
3. Show: description, linked issues, subtask progress, commit count, last activity
4. Optionally fetch issue statuses from GitHub via `gh issue view`

### 5. List: `$ARGUMENTS` is "list"

Example: `/feature-plan list`

Steps:
1. Read `{docs_dir}/INDEX.md`
2. Display the feature table

### 6. Close Feature: `$ARGUMENTS` starts with "close"

Example: `/feature-plan close FT-001`

Steps:
1. Find the feature README.md
2. Update Status to "Shipped"
3. Update the INDEX.md row status
4. Close all linked GitHub issues via `gh issue close`
5. Print confirmation

## Feature Directory Structure

Each feature gets its own directory:

```
docs/features/
├── INDEX.md
├── FT-001-user-auth/
│   ├── README.md              # Main feature doc
│   └── tasks/
│       ├── FT-001.1-setup-oauth.md
│       ├── FT-001.2-login-form.md
│       └── FT-001.3-session-mgmt.md
├── FT-002-payment-flow/
│   ├── README.md
│   └── tasks/
│       └── FT-002.1-stripe-integration.md
```

## Feature Doc Template

When creating a new feature README.md, use this structure:

```markdown
# {ID}: {Feature Name}

- **Status:** Planning
- **Created:** {YYYY-MM-DD}
- **Feature ID:** {ID}

## GitHub Issues

| Repo | Issue | Status |
|------|-------|--------|
<!-- rows added after issue creation -->

## Description

{Brief description — ask the user or use the feature name}

## Subtasks

| ID | Task | Repo | Issue | Status |
|----|------|------|-------|--------|
<!-- rows added by /feature-plan task -->

## Requirements

- [ ] _To be defined_

## Technical Notes

_To be added during implementation._

## Commit Log

| Commit | Repo | Date | Message | Subtask |
|--------|------|------|---------|---------|
```

## Subtask Template

When creating a subtask doc at `tasks/{ID}.{N}-{slug}.md`:

```markdown
# {ID}.{N}: {Task Name}

- **Parent:** [{ID}: {Feature Name}](../README.md)
- **Status:** Todo
- **Created:** {YYYY-MM-DD}

## GitHub Issues

| Repo | Issue | Status |
|------|-------|--------|
<!-- rows added after issue creation -->

## Description

{Brief description of this subtask}

## Acceptance Criteria

- [ ] _To be defined_

## Commit Log

| Commit | Repo | Date | Message |
|--------|------|------|---------|
```

## Index Template

If `{docs_dir}/INDEX.md` doesn't exist, create it:

```markdown
# Feature Index

| ID | Feature | Status | Created | Subtasks | Doc |
|----|---------|--------|---------|----------|-----|
```

Then append the new row:
```
| {ID} | {Feature Name} | Planning | {YYYY-MM-DD} | 0 | [{ID}](./{ID}-{slug}/README.md) |
```

When subtasks are added, update the Subtasks count in INDEX.md for that feature.

## Slug Generation

Convert name to slug: lowercase, replace spaces/special chars with hyphens, trim to 40 chars max.
Example: "User Authentication Flow" -> "user-authentication-flow"

## Commit Convention

After creating a feature or subtask, always remind the user:

```
Commit convention — reference the feature or subtask ID:

  git commit -m "{ID}: your message here"
  git commit -m "{ID}.{N}: your message here"

Examples:
  git commit -m "FT-001: add auth middleware"
  git commit -m "FT-001.2: fix login form validation"
```

## GitHub Issue Cross-Referencing

When creating issues:

**Parent feature issue body:**
```
## Feature: {ID} — {Feature Name}

Feature doc: `{docs_dir}/{ID}-{slug}/README.md`

### Subtasks
<!-- Updated as subtasks are added -->
- [ ] {ID}.1 — {Task Name} (repo#issue)
```

**Subtask issue body:**
```
## Subtask: {ID}.{N} — {Task Name}

Parent feature: {ID} — {Feature Name} (repo#parent-issue)
Subtask doc: `{docs_dir}/{ID}-{slug}/tasks/{ID}.{N}-{task-slug}.md`
```

When a subtask is created, also edit the parent feature issue in each repo to add the subtask to the checklist using `gh issue edit`.

## Important Rules

- Always read `.featurerc.yml` first. If missing, show the template and ask the user to create it.
- Never overwrite an existing feature doc — error if the ID somehow collides.
- Zero-pad feature IDs to 3 digits (001-999). If 999 is reached, use 4 digits.
- Subtask numbers are NOT zero-padded (1, 2, 3...).
- When creating directories, use `mkdir -p`.
- Cross-reference issues: each GitHub issue body should mention the other repo's issue.
- Dates are always `YYYY-MM-DD` format.
- When adding subtasks, update BOTH the feature README.md subtask table AND the parent GitHub issue checklist.
- Subtask status values: Todo, In Progress, Done.
- Feature status values: Planning, In Progress, Shipped, Cancelled.

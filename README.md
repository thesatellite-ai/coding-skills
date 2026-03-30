# Claude Code Skills

A collection of Claude Code skills for feature planning, tracking, and development workflows.

## Quick Install

```bash
git clone https://github.com/thesatellite-ai/coding-skills.git
cd coding-skills
./install.sh
```

Install a specific skill:

```bash
./install.sh feature-plan
```

## Available Skills

### feature-plan

Plan and track features across multiple repos with linked GitHub issues, subtasks, and commit tracking.

**Commands:**

| Command | Example | Description |
|---------|---------|-------------|
| New feature | `/feature-plan User Auth` | Creates feature dir + GitHub issues + index entry |
| Add subtask | `/feature-plan task FT-001 "Setup OAuth"` | Creates subtask doc + sub-issue linked to parent |
| Log commit | `/feature-plan log FT-001 abc1234` | Records a commit in the feature doc |
| Log to subtask | `/feature-plan log FT-001.2 abc1234` | Records a commit in both feature and subtask doc |
| Status | `/feature-plan status FT-001` | Shows feature status, subtasks, and linked issues |
| List | `/feature-plan list` | Displays all tracked features |
| Close | `/feature-plan close FT-001` | Marks shipped, closes GitHub issues |

**What gets created:**

```
docs/features/
├── INDEX.md                          # Master feature list
├── FT-001-user-auth/
│   ├── README.md                     # Feature doc with issues, commits, subtasks
│   └── tasks/
│       ├── FT-001.1-setup-oauth.md   # Subtask with its own issues + commits
│       └── FT-001.2-login-form.md
```

**Setup:** Add `.featurerc.yml` to your project root:

```yaml
# Feature prefix (2-4 chars, uppercase)
prefix: FT

# GitHub repos — issues created in each
repos:
  - your-org/backend
  - your-org/frontend

# Labels for GitHub issues
labels:
  - feature

# Where feature docs live
docs_dir: docs/features
```

See [skills/feature-plan/templates/featurerc-example.yml](skills/feature-plan/templates/featurerc-example.yml) for a full commented example.

**Commit convention:**

```bash
git commit -m "FT-001: add auth middleware"       # Feature-level
git commit -m "FT-001.2: fix login validation"    # Subtask-level
```

## Versioning

Each skill has its own `VERSION` file. Check what you have installed:

```bash
./install.sh -v
```

```
  SKILL                INSTALLED    AVAILABLE    STATUS
  -----                ---------    ---------    ------
  feature-plan         0.1.0        0.2.0        update available
```

To upgrade, `git pull` and re-run `./install.sh`.

## Uninstall

```bash
./uninstall.sh --all          # Remove all skills
./uninstall.sh feature-plan   # Remove specific skill
```

## Adding New Skills

1. Create a directory under `skills/your-skill-name/`
2. Add a `SKILL.md` with frontmatter and instructions
3. Run `./install.sh your-skill-name` to test locally
4. Commit and push

## Directory Structure

```
coding-skills/
├── install.sh
├── uninstall.sh
├── README.md
└── skills/
    └── feature-plan/
        ├── SKILL.md
        └── templates/
            └── featurerc-example.yml
```

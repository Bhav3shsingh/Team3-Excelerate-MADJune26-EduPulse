# Contributing to Excelerate-EduPulse

First off, thank you for taking the time to contribute! It is contributors like you who make this ecosystem thrive. 

To maintain code quality and keep our production environment stable, all contributors—including internal team members—are required to follow this workflow.

---

## 🛑 The Golden Rule
> **Never push directly to the `main` branch.** The `main` branch is strictly protected. All code changes must be introduced through a feature branch and a reviewed Pull Request (PR).

---

## 🛣️ Our Development Workflow

### 1. Branch Naming Conventions
Before writing any code, create a new branch from the latest `main` branch. Use the following naming structures depending on your task:
* `feature/short-description` — For new features or enhancements (e.g., `feature/user-login`).
* `bugfix/short-description` — For fixing bugs or broken code (e.g., `bugfix/api-timeout`).
* `docs/short-description` — For documentation updates only (e.g., `docs/readme-cleanup`).

```bash
# Example: Creating a new feature branch
git checkout main
git pull origin main
git checkout -b feature/auth-implementation
```

### 2. Commit Guidelines
* Keep commits focused and atomic (fix one thing per commit).
* Write clear, imperative commit messages (e.g., Add user authentication module instead of fixed some login stuff).

### 3. Open a Pull Request (PR)
Once your changes are ready and tested locally:
1. Push your branch to GitHub: git push origin feature/your-branch-name
2. Navigate to the repository on GitHub and click Compare & pull request.
3. Fill out the PR template completely (explain what changed and why).

### 4. Code Review & Merging
* Approval Required: At least 1 peer review / maintainer approval is required before a PR can be merged.
* If automated checks or reviews request modifications, push the updates directly to your feature branch. The PR will update automatically.
* Once approved, a project maintainer will merge the branch into main.

🐛 Reporting Bugs & Suggesting Features
If you find a bug or have an idea for a new feature but aren't writing the code yourself:
1. Head over to the Issues tab.
2. Check if the issue has already been reported.
3. If not, open a new issue using a descriptive title and provide as much context, screenshots, or reproduction steps as possible.

Thank you for your cooperation in keeping our codebase clean and organized!

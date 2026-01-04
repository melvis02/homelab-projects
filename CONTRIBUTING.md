# Contributing

Thanks for contributing! A few guidelines to keep things consistent:

## Branching
- Use short-lived feature branches: `feat/<short-description>` or `fix/<short-description>`.
- Use `main` for stable code; open a PR to merge features into `main`.

## Commits & PRs
- Write clear commit messages: `type(scope): short-summary` (e.g., `feat(proxmox): add cloud-init config`).
- Keep commits small and focused.
- Include a concise PR description with motivation and testing notes.

## Code style
- Keep scripts readable and add comments for complex logic.
- Run formatting and linting where applicable before committing.

## Secrets
- Never commit secrets or credentials. Use `terraform.tfvars` (ignored) or environment variables.

## CI & Testing
- If you add automation or tests, include instructions to run them locally.

## Questions
Open an issue or reach out via the maintainer's preferred contact method.

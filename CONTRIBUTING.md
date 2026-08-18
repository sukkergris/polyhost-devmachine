# Contributing

Thanks for contributing to this project.

## Development workflow

1. Fork the repository.
2. Create a feature branch from `main`.
3. Keep changes focused and easy to review.
4. Run the relevant checks before opening a pull request.
5. Submit a pull request with a clear description of the change.

## Local development

Use the provided devcontainer or build the image locally:

```bash
task build
```

For a local devcontainer base build:

```bash
task build:devcontainer-base-local
```

## Coding expectations

- Prefer small, reviewable commits.
- Keep documentation in sync with code changes.
- Avoid committing machine-specific paths, secrets, or personal config.
- Use clear commit messages and include context in the PR.

## Reporting issues

Open an issue with:

- a clear description of the problem
- reproduction steps
- expected vs actual behavior
- version or environment details

## Pull requests

PRs should include:

- a concise summary of the change
- the reason for the change
- verification steps performed
- any follow-up items or known limitations

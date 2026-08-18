# polyhost-devmachine

A Debian-based development machine and devcontainer setup for local software work, container-heavy workflows, and .NET/Node-based development from a reproducible environment.

## What this repo provides

- A Dockerized Debian 13 base image tuned for developer tooling
- A VS Code devcontainer configuration for a root-based workflow
- Preinstalled tooling for:
  - .NET SDK and runtimes
  - Node.js via nvm
  - Git, Docker-friendly utilities, build tools, and SSH support
  - VS Code-adjacent developer setup for a local machine bootstrap
- Task-based automation for building and pushing the image

## Repository layout

- [build/Dockerfile.debian](build/Dockerfile.debian) — the base image definition
- [build/docker-compose.yml](build/docker-compose.yml) — local image build configuration
- [.devcontainer/debian/devcontainer.json](.devcontainer/debian/devcontainer.json) — devcontainer entry point
- [Taskfile.yml](Taskfile.yml) — common build and sync tasks
- [docs/README.md](docs/README.md) — project notes and operational gotchas
- [docs/registry-configuration.md](docs/registry-configuration.md) — registry/tag configuration guide

## Prerequisites

- Docker
- VS Code with the Dev Containers extension
- Git

## Quick start

1. Clone the repo.
2. Open the folder in VS Code.
3. Reopen in the dev container when prompted.
4. Or build the image locally:

```bash
task build
```

For a local base-image build without a registry dependency:

```bash
task build:devcontainer-base-local
```

## Build and publish

The image namespace, repository name, and tag are configured in [build/.env](build/.env).

To push a versioned image:

```bash
task build-and-push
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening an issue or pull request.

## Security

Please review [SECURITY.md](SECURITY.md) before reporting a vulnerability.

## License

This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md).

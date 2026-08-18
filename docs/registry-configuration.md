# Docker registry configuration

The image namespace/name/tag used for both the pushed image and the
devcontainer's base image are controlled from a **single source of truth**:
[`build/.env`](../build/.env).

```dotenv
IMAGE_NAMESPACE=isuperman
IMAGE_NAME=polyhost-devcontainer
IMAGE_TAG=debian-0.0.0
```

[`build/docker-compose.yml`](../build/docker-compose.yml) builds/tags the
image as `${IMAGE_NAMESPACE}/${IMAGE_NAME}:${IMAGE_TAG}`, and `task build` /
`task push` (via [`build/push-with-retry.sh`](../build/push-with-retry.sh))
both read it automatically — Compose resolves `.env` relative to the compose
file's own directory (`build/`), no extra flags needed.

## One repo, multiple tags

`isuperman/polyhost-devcontainer` is one Docker Hub repo shared across every
base-image flavor this project builds — the flavor and version both live in
the **tag**, not the repo name:

- `debian-0.0.0` — this project's Debian devcontainer, current version
- future flavors follow the same pattern, e.g. `alpine-0.0.1`, `arch-0.0.1`

This mirrors the account's existing convention
(`isuperman/<name>`, one repo per project) while keeping this repo's own
variants organized by tag instead of spawning a separate repo per OS flavor.

## Docker Hub's naming rule

**Important:** Docker Hub only accepts a flat `namespace/repository` — two
segments, no nesting. Docker's CLI reference parser only treats the first
path segment as a registry *host* if it contains a `.` or a `:port` (or is
literally `localhost`); anything else is folded into the repository path on
the default registry (`docker.io`, i.e. Docker Hub itself) — silently, with
no error at parse time.

This was verified directly on this project. An earlier version of this file
used a 3-segment scheme (`DOCKER_REGISTRY=dockerhub` as a fake "registry"
prefix), which — because `dockerhub` has no dot — silently resolved through
real Docker Hub as an invalid 3-segment path:

```console
$ docker manifest inspect dockerhub/polyhost/devcontainer.debian.polyhost:0.0.0
errors:
denied: requested access to the resource is denied
unauthorized: authentication required
# ^ hit Docker Hub's real auth service with an invalid 3-segment path

$ docker manifest inspect registry.example.internal:5000/polyhost/devcontainer.debian.polyhost:0.0.0
failed to configure transport: error pinging v2 registry:
Get "https://registry.example.internal:5000/v2/": dial tcp: lookup registry.example.internal: no such host
# ^ a dotted/port host is actually dialed as a distinct registry

$ docker manifest inspect isuperman/polyhost-devcontainer:debian-0.0.0
no such manifest: docker.io/isuperman/polyhost-devcontainer:debian-0.0.0
# ^ current scheme: clean 2-segment lookup against the real account,
#   correctly reports "doesn't exist yet" rather than an error
```

`docker login` (or CI-provided credentials) is expected to happen
separately — nothing here scripts authentication.

## Switching to a private registry later

If this ever needs to move off Docker Hub to a private registry, set
`IMAGE_NAMESPACE` to include the registry host, e.g.:

```dotenv
IMAGE_NAMESPACE=registry.mycompany.com/polyhost
```

Docker treats the leading `registry.mycompany.com` (has a dot) as the
registry host and the rest as the nested repository path — private
registries generally support arbitrary path depth, unlike Docker Hub.

## Keeping the devcontainer's base image in sync

The devcontainer (`.devcontainer/debian/`) builds
[`Dockerfile.devmachine`](../.devcontainer/debian/Dockerfile.devmachine) FROM
`${DEVCONTAINER_BASE_IMAGE}:${IMAGE_TAG}`, read from its own
`.devcontainer/debian/.env`. That file is **generated, not hand-maintained** —
editing it directly will just get overwritten.

- [`.devcontainer/scripts/sync-build-env.sh`](../.devcontainer/scripts/sync-build-env.sh)
  reads `build/.env` and writes `.devcontainer/debian/.env`:

  ```dotenv
  DEVCONTAINER_BASE_IMAGE=${IMAGE_NAMESPACE}/${IMAGE_NAME}
  IMAGE_TAG=${IMAGE_TAG}
  ```

- It runs automatically via `devcontainer.json`'s `initializeCommand`, on the
  host, every time VS Code (re)builds the devcontainer — so a namespace/tag
  change in `build/.env` always reaches the devcontainer without a second
  manual edit.
- Run it manually any time with `task devcontainer:sync-env`.

So the only file you ever need to edit to change the image name, tag, or
registry is `build/.env`; everything else (image build/push, and the
devcontainer base image) follows from it automatically.

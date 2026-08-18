# Docs

## Known gotcha: root's `PATH` gets reset on login shells

**Symptom:** `dotnet`, `csharp-ls`, `dotnet-script`, `csharpier`, and `dotnet-format`
are all installed and on `PATH` inside the image (`ENV PATH=...` in
[`build/Dockerfile.debian`](../build/Dockerfile.debian)), but they disappear —
`command not found` — as soon as you're in a **login** shell:

```console
$ docker exec -it <container> bash -l
$ dotnet --version
bash: dotnet: command not found
```

A plain `docker exec -it <container> bash` (non-login) is unaffected, and so is
the zsh terminal VS Code opens by default (per `.devmachine/debian/devcontainer.json`'s
`terminal.integrated.defaultProfile.linux: zsh`) — which is why this can go
unnoticed for a while.

**Root cause:** Debian's `/etc/profile` unconditionally resets `PATH` for root,
on every login shell (`bash -l`, `su -`, an SSH session):

```sh
if [ "$(id -u)" -eq 0 ]; then
  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
else
  ...
fi
export PATH
```

This runs *after* Docker's `ENV PATH=...` has set the process environment, and
a login bash shell always sources `/etc/profile`. That wipes out
`/opt/dotnet`, `/opt/dotnet/tools`, and `/root/.dotnet/tools` — everywhere the
.NET SDK, runtimes, and `dotnet tool install --global` binaries live — leaving
only the stock `/usr/local/*:/usr/*:/*` paths. zsh isn't affected because
there's no equivalent reset in `/etc/zsh/zprofile` in this image.

**Fix:** [`build/Dockerfile.debian`](../build/Dockerfile.debian) writes
`/etc/profile.d/00-devmachine-path.sh`, which re-exports the full `PATH`.
Scripts under `/etc/profile.d/` are sourced by `/etc/profile` *after* the
root `PATH` reset line, so this survives regardless of shell or login mode.

Verified by rebuilding the image and confirming `dotnet`/`csharp-ls` etc.
resolve correctly under `bash -lc '...'` as well as plain `bash -c '...'`
and `zsh -lic '...'`.

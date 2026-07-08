# DAGForge runner

Source for the public **[`DAGForge-Team/dagforge-run`](https://github.com/DAGForge-Team/dagforge-run)**
repo — the one-line launcher for the self-contained DAGForge demo. These files carry no secrets (they
only reference the public GHCR image), so they live in a public repo even while the main code repo stays
private.

It's a *runner*, not an installer: it pulls the image, runs it in the foreground, and tears it down on
Ctrl-C — nothing is installed persistently (state lives under `~/.dagforge`).

## What's here

- **`run.sh`** — detects Docker/Podman compose, writes a small compose file under `~/.dagforge`, starts
  the demo image (mock stack, no keys), opens the browser, follows logs, and stops the container on
  Ctrl-C.

## Launch command

Because `dagforge-run` is public, the raw URL works with no extra hosting:

```bash
curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/dagforge-run/main/run.sh | bash
```

Want a prettier URL? Enable GitHub Pages on `dagforge-run` and serve `run.sh` from there
(`https://dagforge-team.github.io/dagforge-run/run.sh`) — optional; the raw URL above already works.

## Prerequisite: the image must be public

`run.sh` pulls `ghcr.io/dagforge-team/dagforge:latest` anonymously. Publish it once (git tag `v*` or a
manual run of the `Publish container image` workflow in the main repo), then flip the GHCR package to
**Public** in its settings. Until then, `run.sh` fails at the pull step — everything before it (the
compose file, engine detection) works, only the anonymous pull needs the flip.

## Updating

`run.sh` is the source of truth here in the main repo under `deploy/runner/`. To update the public repo,
copy this `run.sh` (and this README) into a checkout of `dagforge-run` and push.

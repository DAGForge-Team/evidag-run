# Run the DAGForge demo

Constructing causal directed acyclic graphs (DAGs) remains a manual process and a bottleneck to studies that require causal inference. DAGForge is a browser-based system that converts free-text study concepts into auditable causal DAGs through a literature-backed, UMLS-enhanced, and evidence-traceable pipeline. This repo is a one-command launcher that runs the whole app on your own
machine, in a single container. No account or source checkout is needed — just Docker (or Podman) and
the command below.

## Run it

```bash
curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/dagforge-run/main/run.sh | bash
```

The first run pulls the demo image (a few hundred MB — give it a minute), starts it, and opens
**http://localhost:8000** in your browser, already signed in.

- **Stop it** — press **Ctrl-C** in the terminal. The container is removed; nothing is installed
  on your system (scratch state lives under `~/.dagforge`).
- **Signed out?** Log back in with **`admin@dagforge.local`** / **`dagforge`**.
- **Want to read the script before running it?**
  `curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/dagforge-run/main/run.sh -o run.sh`,
  read it, then `bash run.sh`.

You'll need **Docker** or **Podman** installed
([get Docker](https://docs.docker.com/get-docker/) · [get Podman](https://podman.io/get-started/)).
A compose plugin is used when present; a plain `docker`/`podman` install works too.

## What you'll see

Out of the box the demo runs **fully offline on a mock stack** — no API keys, no network calls.
It comes seeded with one finished run, so you can explore right away: browse the generated DAG,
its identification analysis and PRISMA record, the provenance trail, and submit your own run to
watch the pipeline progress end to end. The pipeline results are canned, so this is the
quickest way to see the whole interface.

## See the real pipeline (bring your own LLM key)

To run the **real** pipeline against a live model, give the container a provider and an API key (credits needed),
then relaunch. Keys stay on your machine — they're read from a local env file and are never
entered in the web UI.

1. Create **`~/.dagforge/.env`** with the real pipeline switched on, plus your provider and key:

   ```dotenv
   DAGFORGE_MODE=live
   LLM_PROVIDER=anthropic
   LLM_MODEL=claude-sonnet-4-6 
   OPENAI_API_KEY=sk-...
   ANTHROPIC_API_KEY=sk-...
   # UMLS_API_KEY=...   # required for the default UMLS enrichment (Submit is rejected without it); parser_only needs no key
   # NCBI_API_KEY=...   # optional but recommended - significantly improves literature search retrieval time
   ```

2. Run the same command again:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/dagforge-run/main/run.sh | bash
   ```

The launcher picks up `~/.dagforge/.env` automatically. Until you set `DAGFORGE_MODE=live` above, the
demo stays on the mock stack — **a key on its own doesn't start spending**. Real runs take a few
minutes each and use your provider's credits.

### Providers

| Provider | `LLM_PROVIDER` | Credentials in `~/.dagforge/.env` |
| --- | --- | --- |
| OpenAI | `openai` | `OPENAI_API_KEY=sk-...` |
| Anthropic | `anthropic` | `ANTHROPIC_API_KEY=sk-ant-...` |
| Local, OpenAI-compatible (e.g. Ollama) | `local` | `LOCAL_LLM_BASE_URL=...`, `LOCAL_LLM_API_KEY=...` |

Set `LLM_MODEL` to a model your provider serves — e.g. `claude-opus-4-6` (recommended), `gpt-5.5`, `qwen2.5-coder`.
A local endpoint has to be reachable *from inside the container*, so point `LOCAL_LLM_BASE_URL` at
your host's container address (e.g. `http://host.docker.internal:11434/v1`), not `localhost`. (Note: Local LLM support is currently disabled) 


## Handy knobs

Set these in the shell before the command (e.g. `curl -fsSL … | DAGFORGE_PORT=8080 bash`):

- `DAGFORGE_PORT` — host port (default `8000`).
- `DAGFORGE_PULL` — `always` (default), `missing`, or `never` once the image is cached.
- `DAGFORGE_NO_BANNER=1` — skip the startup banner.

---

This repo holds a single script, **`run.sh`** — the launcher. It pulls the public image
`ghcr.io/dagforge-team/dagforge:latest`, runs it, and cleans up on exit. No secrets and no source
code; the DAGForge codebase lives elsewhere.

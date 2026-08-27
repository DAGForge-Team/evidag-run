# EviDAG

Constructing causal directed acyclic graphs (DAGs) is central to observational biomedical research, but it remains a manual process requiring analysts to connect study variables with prior literature, judge uncertain causal claims, and preserve enough provenance for expert review. We present EviDAG, a browser-based system for drafting causal DAGs as auditable evidence artifacts. Given free-text study concepts, EviDAG creates a reproducible literature snapshot, uses an LLM-based causal reasoning module to make structured pairwise causal judgments with verbatim citation grounding, and assembles these judgments into a constraint-checked graph whose edges expose confidence, provenance, and reviewable rationale. The interface supports study submission, progress inspection, evidence-card review, graph comparison, adjustment-set computation, and export. In benchmarks against compact and published literature reference DAGs, EviDAG achieves high recall on the literature cohort while preserving verifiable evidence trails that LLM-only baselines lack. EviDAG demonstrates a traceable workflow for literature-linked causal DAG authoring, keeping automation inspectable and replayable for scientific review.

## Run the EviDAG demo

This repository is a one-command launcher that runs the full application on your own machine in
a single container. No account or source checkout is required — only Docker or Podman and the
command below.

```bash
curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/evidag-run/main/run.sh | bash
```

The first run pulls the demo image (a few hundred MB; the initial pull may take a minute), starts
it, and opens **http://localhost:8000** in your browser, already signed in.

- **To inspect the script before running it:**
  `curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/evidag-run/main/run.sh -o run.sh`,
  review it, then run `bash run.sh`.
- **To stop the demo:** press **Ctrl-C** in the terminal. The container is removed; nothing is
  installed on your system (scratch state lives under `~/.evidag`).
- **To sign back in:** use **`admin@evidag.local`** / **`evidag`**.

**Docker** or **Podman** is required
([get Docker](https://docs.docker.com/get-docker/) · [get Podman](https://podman.io/get-started/)).
A compose plugin is used when present; a plain `docker` or `podman` installation also works.

For upgrade compatibility, the launcher reuses an existing `~/.dagforge` directory when
`~/.evidag` does not exist yet. Legacy `DAGFORGE_*` configuration variables are also accepted when
their corresponding `EVIDAG_*` variables are absent.

## What the demo includes

By default the demo runs **fully offline on a mock stack**, with no API keys and no network calls.
It is seeded with one completed run, so you can explore the interface immediately: browse the
generated DAG, its identification analysis and PRISMA record, and the provenance trail, or submit
your own run to watch the pipeline progress end to end. The pipeline results are canned,
making this the fastest way to review the full interface.

## Running the real pipeline

To run the **real** pipeline against a live model, provide the container with a provider and an API
key, then relaunch. Keys remain on your machine: they are read from a local env file and are never
entered in the web UI.

1. Create **`~/.evidag/.env`** with the real pipeline enabled, along with your provider and key:

   ```dotenv
   EVIDAG_MODE=live
   LLM_PROVIDER=openai
   LLM_MODEL=gpt-4o
   OPENAI_API_KEY=sk-...
   # UMLS_API_KEY=...   # required for the default UMLS enrichment; parser_only runs need no key
   ```

2. Run the same command again:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/evidag-run/main/run.sh | bash
   ```

The launcher picks up `~/.evidag/.env` automatically. Until `EVIDAG_MODE=live` is set, the demo
remains on the mock stack: **a provider key alone does not trigger real runs**. Real runs take a few
minutes each and consume your provider's credits.

### Providers

| Provider | `LLM_PROVIDER` | Credentials in `~/.evidag/.env` |
| --- | --- | --- |
| OpenAI | `openai` | `OPENAI_API_KEY=sk-...` |
| Anthropic | `anthropic` | `ANTHROPIC_API_KEY=sk-ant-...` |
| Local, OpenAI-compatible (e.g. Ollama) | `local` | `LOCAL_LLM_BASE_URL=...`, `LOCAL_LLM_API_KEY=...` |

Set `LLM_MODEL` to a model your provider serves (for example `gpt-4o`, `claude-opus-4-7`, or
`qwen2.5-coder`). A local endpoint must be reachable *from inside the container*, so point
`LOCAL_LLM_BASE_URL` at your host's container address (for example
`http://host.docker.internal:11434/v1`) rather than `localhost`.

## Configuration

Set these in the shell before the command (for example `curl -fsSL … | EVIDAG_PORT=8080 bash`):

- `EVIDAG_PORT` — host port (default `8000`).
- `EVIDAG_PULL` — `always` (default), `missing`, or `never` once the image is cached.
- `EVIDAG_NO_BANNER=1` — skip the startup banner.

---

#!/usr/bin/env bash
# DAGForge one-line launcher.
#
#   curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/dagforge-run/main/run.sh | bash
#
# Detects Docker or Podman compose, writes a small compose file under ~/.dagforge, starts the
# self-contained demo image (mock stack — no API keys, no network), opens your browser, and follows the
# logs. Ctrl-C stops and removes the container. The image is pinned to a public GHCR package; nothing
# here needs a checkout of the source repo.
#
# Prefer to read before you run? Save it first:
#   curl -fsSL https://raw.githubusercontent.com/DAGForge-Team/dagforge-run/main/run.sh -o run.sh && less run.sh
set -euo pipefail

IMAGE="${DAGFORGE_IMAGE:-ghcr.io/dagforge-team/dagforge:latest}"
PORT="${DAGFORGE_PORT:-8000}"
URL="http://localhost:${PORT}"
STATE_DIR="${DAGFORGE_HOME:-$HOME/.dagforge}"
COMPOSE_FILE="${STATE_DIR}/compose.yaml"

# ── Banner ─────────────────────────────────────────────────────────────────────────────────────────
# Coral wordmark on brand (--ds-color-coral #ff7759 / -coral-soft #ffad9b), truecolor with a 256-color
# fallback. Color only when stdout is a terminal and NO_COLOR is unset; otherwise plain text. Set
# DAGFORGE_NO_BANNER=1 to skip it.
banner() {
  [ -n "${DAGFORGE_NO_BANNER:-}" ] && return 0
  local CORAL='' SOFT='' D='' R=''
  if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    if [ "${COLORTERM:-}" = "truecolor" ] || [ "${COLORTERM:-}" = "24bit" ]; then
      CORAL=$'\033[38;2;255;119;89m'   # --ds-color-coral #ff7759
      SOFT=$'\033[38;2;255;173;155m'   # --ds-color-coral-soft #ffad9b
    else
      CORAL=$'\033[38;5;209m'          # nearest 256-color coral
      SOFT=$'\033[38;5;216m'           # nearest 256-color soft coral
    fi
    D=$'\033[2m'
    R=$'\033[0m'
  fi
  printf '%s' "$CORAL"
  cat <<'ART'

    ____  ___   ____________
   / __ \/   | / ____/ ____/___  _________ ____
  / / / / /| |/ / __/ /_  / __ \/ ___/ __ `/ _ \
 / /_/ / ___ / /_/ / __/ / /_/ / /  / /_/ /  __/
/_____/_/  |_\____/_/    \____/_/   \__, /\___/
                                   /____/
ART
  printf '%s   %s(exposure) ─▶ (mediator) ─▶ (outcome)%s\n' "$R" "$SOFT" "$R"
  printf '%s   Automated Causal DAG Generation · self-contained demo%s\n\n' "$D" "$R"
}
banner

# ── Pick a compose engine (docker compose ▸ podman compose ▸ legacy shims) ─────────────────────────
if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif podman compose version >/dev/null 2>&1; then
  COMPOSE="podman compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
elif command -v podman-compose >/dev/null 2>&1; then
  COMPOSE="podman-compose"
else
  echo "error: Docker or Podman (with compose) is required but neither was found." >&2
  echo "  Docker Desktop: https://docs.docker.com/get-docker/" >&2
  echo "  Podman:         https://podman.io/get-started/" >&2
  exit 1
fi
echo "[dagforge] engine: ${COMPOSE}"

# ── Materialize the compose file (idempotent) ─────────────────────────────────────────────────────
mkdir -p "${STATE_DIR}"
cat > "${COMPOSE_FILE}" <<YAML
name: dagforge
services:
  dagforge:
    image: ${IMAGE}
    pull_policy: always
    ports:
      - "${PORT}:8000"
YAML

echo "[dagforge] The demo runs offline on a mock stack — no API keys needed."
echo "[dagforge] For real pipeline runs, put your provider + key in ${STATE_DIR}/.env and re-run"
echo "           (start it with M6_RUN_ORCHESTRATOR_FACTORY=apps.web_application.composition.build_real_orchestrator)."
if [ -f "${STATE_DIR}/.env" ]; then
  cat >> "${COMPOSE_FILE}" <<YAML
    env_file:
      - ${STATE_DIR}/.env
YAML
  echo "[dagforge] loading ${STATE_DIR}/.env"
fi

# ── Start, open the browser, follow logs; Ctrl-C tears down ────────────────────────────────────────
cleanup() { echo; echo "[dagforge] stopping…"; ${COMPOSE} -f "${COMPOSE_FILE}" down; }
trap cleanup INT TERM

echo "[dagforge] starting (first run pulls the image — a few hundred MB, give it a minute)…"
${COMPOSE} -f "${COMPOSE_FILE}" up -d

open_browser() {
  if command -v open >/dev/null 2>&1; then open "$1" >/dev/null 2>&1 || true
  elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$1" >/dev/null 2>&1 || true
  elif command -v wslview >/dev/null 2>&1; then wslview "$1" >/dev/null 2>&1 || true
  fi
}

printf '[dagforge] waiting for %s ' "${URL}"
for _ in $(seq 1 90); do
  if curl -fsS "${URL}/" >/dev/null 2>&1; then echo "— ready."; break; fi
  printf '.'; sleep 2
done

echo "[dagforge] open ${URL}  ·  login: admin@dagforge.local / dagforge  ·  Ctrl-C to stop"
open_browser "${URL}"

# Foreground log follow. Ctrl-C interrupts this, the trap runs, and the container is removed.
${COMPOSE} -f "${COMPOSE_FILE}" logs -f

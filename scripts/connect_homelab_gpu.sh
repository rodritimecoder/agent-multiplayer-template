#!/usr/bin/env bash

QUIET="${1:-}"

if [[ -n "${HOMELAB_LITELLM_URL:-}" && -n "${HOMELAB_LITELLM_KEY:-}" ]]; then
  if curl -sSf -m 2 -H "Authorization: Bearer ${HOMELAB_LITELLM_KEY}" "${HOMELAB_LITELLM_URL}/models" >/dev/null 2>&1; then
    export OPENAI_API_BASE="${HOMELAB_LITELLM_URL}"
    export OPENAI_BASE_URL="${HOMELAB_LITELLM_URL}"
    export OPENAI_API_KEY="${HOMELAB_LITELLM_KEY}"
    [[ "$QUIET" != "--quiet" ]] && echo "[GPU Bridge] Connected to Homelab GPU Rig (${HOMELAB_LITELLM_URL})"
    return 0 2>/dev/null || exit 0
  fi
fi

# Fallback to OpenRouter Free if Homelab PC is asleep/offline
if [[ -n "${OPENROUTER_API_KEY:-}" ]]; then
  export OPENAI_API_BASE="https://openrouter.ai/api/v1"
  export OPENAI_BASE_URL="https://openrouter.ai/api/v1"
  export OPENAI_API_KEY="${OPENROUTER_API_KEY}"
  [[ "$QUIET" != "--quiet" ]] && echo "[GPU Bridge] Homelab PC offline -> Routed to OpenRouter Free API."
fi

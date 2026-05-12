#!/usr/bin/env bash
# effective-html installer
# Installs the skill globally for Claude Code, and optionally installs
# the Playground plugin and Agentation MCP server.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DEST="${HOME}/.claude/skills/effective-html"
ARTIFACTS_DIR="${HOME}/.claude/artifacts"
CONFIG_FILE="${SKILL_DEST}/.config.json"

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
dim()  { printf "\033[2m%s\033[0m\n" "$1"; }
ok()   { printf "\033[32m✓\033[0m %s\n" "$1"; }
warn() { printf "\033[33m!\033[0m %s\n" "$1"; }
err()  { printf "\033[31m✗\033[0m %s\n" "$1"; }

ask_yn() {
  # ask_yn "Prompt" "default(y|n)"
  local prompt="$1" default="${2:-n}" reply
  local hint="[y/N]"; [ "$default" = "y" ] && hint="[Y/n]"
  read -r -p "$prompt $hint " reply || true
  reply="${reply:-$default}"
  case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

# --- arg parsing for non-interactive "add" mode ---
ADD_ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --add) shift; ADD_ONLY="${1:-}"; shift || true ;;
    -h|--help)
      cat <<EOF
Usage: install.sh                       Interactive install (skill + prompts for extras)
       install.sh --add playground      Install only the Playground plugin
       install.sh --add agentation      Install only the Agentation MCP
EOF
      exit 0 ;;
    *) err "Unknown arg: $1"; exit 1 ;;
  esac
done

install_skill() {
  bold "Installing the effective-html skill globally"
  mkdir -p "${SKILL_DEST}"
  rsync -a --delete \
    --exclude '.config.json' \
    "${REPO_DIR}/skill/" "${SKILL_DEST}/"
  cp -r "${REPO_DIR}/templates" "${SKILL_DEST}/templates"
  ok "Skill installed at ${SKILL_DEST}"

  mkdir -p "${ARTIFACTS_DIR}"
  if [ ! -f "${ARTIFACTS_DIR}/index.html" ]; then
    cp "${REPO_DIR}/templates/index.html.tmpl" "${ARTIFACTS_DIR}/index.html"
    ok "Created global artifact index: ${ARTIFACTS_DIR}/index.html"
  else
    dim "Global artifact index already exists, leaving as-is."
  fi
}

write_config() {
  local pg="${1:-false}" ag="${2:-false}"
  cat > "${CONFIG_FILE}" <<EOF
{
  "playground_installed": ${pg},
  "agentation_installed": ${ag},
  "installed_at": "$(date -u +%FT%TZ)"
}
EOF
  ok "Wrote config: ${CONFIG_FILE}"
}

read_config_flag() {
  local key="$1"
  [ -f "${CONFIG_FILE}" ] || { echo "false"; return; }
  grep -E "\"${key}\"" "${CONFIG_FILE}" | grep -q "true" && echo "true" || echo "false"
}

install_playground() {
  bold "Installing the Playground plugin"
  if command -v claude >/dev/null 2>&1; then
    if claude plugin install playground; then
      ok "Playground plugin installed."
      return 0
    fi
  fi
  warn "Could not auto-install. Run this manually in Claude Code:"
  echo "    /plugin install playground"
  return 1
}

install_agentation() {
  bold "Installing the Agentation MCP server"
  if ! command -v npx >/dev/null 2>&1; then
    err "npx not found. Install Node.js first (https://nodejs.org)."
    return 1
  fi
  if ! command -v claude >/dev/null 2>&1; then
    err "claude CLI not found. Install Claude Code first."
    return 1
  fi

  # Register the MCP at user scope (global). Avoid `agentation-mcp init` —
  # its wizard suppresses later prompts under non-TTY stdin and silently
  # exits 0 without finishing registration.
  echo "Registering Agentation MCP with Claude Code (user scope)..."

  # Remove any pre-existing registration so we don't double-add.
  claude mcp remove agentation >/dev/null 2>&1 || true

  if claude mcp add --scope user agentation -- npx -y agentation-mcp server --mcp-only; then
    ok "Agentation MCP registered at user scope."
    dim "Verify with:  claude mcp list | grep agentation"
    dim "It runs on-demand via npx — no separate server start needed."
    return 0
  fi

  err "Agentation registration failed. Manual command:"
  echo "    claude mcp add --scope user agentation -- npx -y agentation-mcp server --mcp-only"
  return 1
}

# --- "add" mode: just add a single extra to an existing install ---
if [ -n "${ADD_ONLY}" ]; then
  [ -f "${CONFIG_FILE}" ] || { err "Skill not installed yet. Run install.sh with no args first."; exit 1; }
  PG=$(read_config_flag playground_installed)
  AG=$(read_config_flag agentation_installed)
  case "${ADD_ONLY}" in
    playground) install_playground && PG="true" ;;
    agentation) install_agentation && AG="true" ;;
    *) err "Unknown component: ${ADD_ONLY} (valid: playground, agentation)"; exit 1 ;;
  esac
  write_config "${PG}" "${AG}"
  exit 0
fi

# --- interactive flow ---
bold "effective-html installer"
echo
echo "This will install:"
echo "  1. The effective-html Claude skill at ${SKILL_DEST}"
echo "  2. A global artifact directory at ${ARTIFACTS_DIR}"
echo
echo "Then it will offer two optional integrations:"
echo "  - Playground plugin (Anthropic-official; interactive controls + live preview)"
echo "  - Agentation MCP (click-to-annotate in the browser + feedback loop to Claude)"
echo
ask_yn "Continue?" "y" || { dim "Aborted."; exit 0; }

install_skill
echo

PG="false"; AG="false"
if ask_yn "Install the Playground plugin?" "y"; then
  install_playground && PG="true" || true
fi
echo

if ask_yn "Install the Agentation MCP (annotation feedback loop)?" "n"; then
  echo
  warn "Heads up: Agentation is under the PolyForm Shield 1.0.0 license."
  warn "Personal/local use is fine. Commercial competing products are restricted."
  if ask_yn "Proceed?" "y"; then
    install_agentation && AG="true" || true
  fi
fi
echo

write_config "${PG}" "${AG}"

echo
bold "Done."
echo "Try it: in Claude Code, type   /preview a comparison of approach A and approach B"
echo "Global index:                  open ${ARTIFACTS_DIR}/index.html"
echo "Uninstall:                     ${REPO_DIR}/uninstall.sh"

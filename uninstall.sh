#!/usr/bin/env bash
# effective-html uninstaller
set -euo pipefail

SKILL_DEST="${HOME}/.claude/skills/effective-html"
ARTIFACTS_DIR="${HOME}/.claude/artifacts"

bold() { printf "\033[1m%s\033[0m\n" "$1"; }
ok()   { printf "\033[32m✓\033[0m %s\n" "$1"; }
dim()  { printf "\033[2m%s\033[0m\n" "$1"; }

ask_yn() {
  local prompt="$1" default="${2:-n}" reply
  local hint="[y/N]"; [ "$default" = "y" ] && hint="[Y/n]"
  read -r -p "$prompt $hint " reply || true
  reply="${reply:-$default}"
  case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

bold "effective-html uninstaller"
echo

if [ -d "${SKILL_DEST}" ]; then
  if ask_yn "Remove the skill at ${SKILL_DEST}?" "y"; then
    rm -rf "${SKILL_DEST}"
    ok "Skill removed."
  fi
else
  dim "Skill not installed."
fi

if [ -d "${ARTIFACTS_DIR}" ]; then
  if ask_yn "Remove your artifacts directory at ${ARTIFACTS_DIR}? (contains generated HTML)" "n"; then
    rm -rf "${ARTIFACTS_DIR}"
    ok "Artifacts directory removed."
  else
    dim "Keeping artifacts."
  fi
fi

echo
dim "Note: this script does NOT uninstall the Playground plugin or Agentation."
dim "  Playground:  in Claude Code, run   /plugin remove playground"
dim "  Agentation:  remove the MCP from your Claude Code config or run  claude mcp remove agentation"

echo
bold "Done."

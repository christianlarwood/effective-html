# Installation guide

## Requirements

- macOS or Linux (the `open`/`xdg-open` auto-open assumes one of these).
- [Claude Code](https://claude.com/claude-code) installed and authenticated.
- `bash`, `rsync`, `git`. For optional Agentation: `node` + `npx`.

## Quick install (interactive)

```bash
git clone https://github.com/christianlarwood/effective-html.git
cd effective-html
./install.sh
```

The installer will prompt you about each component:

| Step | What it does | Required? |
|---|---|---|
| Install skill | Copies skill files to `~/.claude/skills/effective-html/` | Yes |
| Create artifacts dir | Creates `~/.claude/artifacts/` + global index page | Yes |
| Playground plugin | Anthropic-official plugin for interactive HTML with live controls | Recommended |
| Agentation MCP | Click-to-annotate in browser + feedback loop to Claude | Optional |

A `.config.json` is written at `~/.claude/skills/effective-html/.config.json` recording which extras were installed. The skill reads this at runtime to decide whether to suggest Playground / inject the Agentation toolbar.

## Add an extra later

```bash
./install.sh --add playground
./install.sh --add agentation
```

## Verify

In Claude Code, type:

```
/preview a quick test page that says "hello world"
```

You should get clarifying questions (the interview-to-95% rule), then an HTML file in `~/.claude/artifacts/<today>/` that opens in your browser.

## Troubleshooting

**"claude: command not found" during Playground install.**
Open Claude Code and run `/plugin install playground` manually.

**Agentation install fails.**
Make sure Node 18+ is installed (`node --version`). The install runs `npx -y agentation-mcp init` which prompts you to register with Claude Code. If that fails, see [the Agentation repo](https://github.com/benjitaylor/agentation) for manual setup.

**Artifacts not opening in browser.**
On macOS the skill uses `open <file>`. On Linux it uses `xdg-open`. Otherwise the skill just prints the path — open it yourself.

**Skill not triggering.**
Restart Claude Code after installing. Confirm `~/.claude/skills/effective-html/SKILL.md` exists.

## Uninstall

```bash
./uninstall.sh
```

Removes the skill. Asks before removing your artifacts folder (default: keep). Does not remove Playground or Agentation; instructions are printed.

## Opting out of extras after install

To turn off the Agentation toolbar without uninstalling the MCP, edit `~/.claude/skills/effective-html/.config.json` and set `agentation_installed` to `false`. Same for `playground_installed`.

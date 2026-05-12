# html-artifact

A Claude Code skill that produces self-contained HTML artifacts instead of walls of markdown — when an interactive page, diagram, diff, comparison, or deck would communicate better than prose.

Based on [dogum/html-artifacts](https://github.com/dogum/html-artifacts) (Apache 2.0), extended with:

- **Hard 95% interview rule** baked into the skill itself — Claude asks clarifying questions before building, regardless of the installer's `CLAUDE.md`.
- **`/preview` slash trigger** for explicit "make this an HTML page" requests, plus a hybrid offer flow for borderline cases.
- **Project-aware artifact paths** — artifacts go in `./artifacts/claude-html/` inside git repos, or `~/.claude/artifacts/<date>/` for one-off tasks.
- **Global artifact index** at `~/.claude/artifacts/index.html` listing everything across projects.
- **Auto-open** in your default browser after write.
- **Playground plugin routing** for artifacts that need live controls + state.
- **Agentation annotation loop** (opt-in) — click-to-annotate in the browser, Claude waits for your feedback via MCP and iterates.
- **Stay-silent rule** during unrelated tasks. No nagware.

## Install

```bash
git clone https://github.com/christianlarwood/html-artifact.git
cd html-artifact
./install.sh
```

The installer is interactive. It will:

1. Install the skill globally at `~/.claude/skills/html-artifact/`.
2. Create the global artifact directory at `~/.claude/artifacts/`.
3. Ask if you want the Playground plugin (recommended).
4. Ask if you want the Agentation MCP for browser annotations (optional).

Both extras are opt-in and can be added later with `./install.sh --add playground` or `./install.sh --add agentation`.

## Use

In Claude Code:

```
/preview a side-by-side comparison of options A and B for the new onboarding flow
```

Claude will ask a couple of clarifying questions (the skill enforces an interview-to-95%-confidence rule), then generate a single `.html` file, drop it in the right folder, and open it in your browser. If Agentation is installed, the artifact will have a click-to-annotate toolbar; tell Claude "iterate" and it will wait for your annotations and regenerate.

You can also describe what you want without the slash:

> "Write me a plan for the auth migration"

Claude will offer HTML for borderline cases ("Want this as an interactive page or a markdown summary?") and reach for HTML automatically on strong-signal requests (plans, specs, mockups, decks, comparisons, post-mortems, etc.).

## Uninstall

```bash
./uninstall.sh
```

This removes the skill and (optionally) the global artifacts folder. It does *not* remove the Playground plugin or Agentation — instructions are printed at the end.

## What the skill enforces

- Before any non-trivial HTML build, Claude interviews the user to ≥95% confidence on intent, audience, scope, and "done" criteria. This rule is in `SKILL.md` so it applies to every installer regardless of their own `CLAUDE.md`.
- Single self-contained `.html` file (no build step, no bundler).
- Mobile responsive, works offline, real layout (not stacked headers), tasteful typography.
- For interactive editors: a "copy as markdown/JSON/prompt" button so state round-trips back to text.

## What's not in v1

- **Sharing & multi-user annotations.** Agentation itself supports threaded human↔agent conversation, but a "share this with a teammate so they can annotate" flow needs hosted infra. Tracked as future work.
- **Non-HTML artifact formats** (e.g., generating a PDF or a real React app). Out of scope.

## Credits

- [Greg Dogum](https://github.com/dogum) — `dogum/html-artifacts`, the base skill (Apache 2.0).
- [Thariq Shihipar](https://thariqs.github.io/html-effectiveness/) — the original thesis on HTML effectiveness.
- [Benji Taylor](https://github.com/benjitaylor/agentation) — Agentation, the annotation toolkit (PolyForm Shield 1.0.0).
- Anthropic — Claude Code, the Playground plugin.

## License

Apache 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

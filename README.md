# html-artifact

A Claude Code skill that produces self-contained HTML artifacts instead of walls of markdown — when an interactive page, diagram, diff, comparison, or deck would communicate better than prose.

Based on [dogum/html-artifacts](https://github.com/dogum/html-artifacts) (Apache 2.0), extended with:

- **Hard 95% interview rule** baked into the skill itself — Claude asks clarifying questions before building, regardless of the installer's `CLAUDE.md`.
- **`/preview` slash trigger** for explicit "make this an HTML page" requests, plus a hybrid offer flow for borderline cases.
- **Project-aware artifact paths** — artifacts go in `./artifacts/claude-html/` inside git repos, or `~/.claude/artifacts/<date>/` for one-off tasks.
- **Global artifact index** at `~/.claude/artifacts/index.html` listing everything across projects.
- **Auto-open** in your default browser after write.
- **Playground plugin routing** for artifacts that need live controls + state.
- **Agentation annotation loop** (opt-in, selective) — click-to-annotate in the browser, Claude waits for your feedback via MCP and iterates. The toolbar is only injected on iterable artifacts (mockups, drafts, prototypes), not on finished reports or static diagrams. Claude auto-starts the Agentation HTTP server when needed; you kill it with `pkill -f agentation-mcp` when done.
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

- **Sharing & multi-user annotations.** See the roadmap below.
- **Non-HTML artifact formats** (e.g., generating a PDF or a real React app). Out of scope.

## Roadmap: sharing artifacts with others

Three tiers worth considering, in increasing effort:

### Tier 1 — Read-only share (~1 day)

Drop the `.html` on a static host (S3, Cloudflare R2, Vercel, GitHub Pages, Notion attachment). Artifacts are already self-contained — no build needed. A `/preview --share` flag would upload to a configured bucket and print the URL. Recipients open the link and read; no annotations come back.

**Worth building soon.** High value, low effort, no third-party dependency. Solves the most common "send this to my teammate" need.

### Tier 2 — Share + plain-text feedback (~3 days)

Same upload, plus a feedback form appended to the artifact pointing at a webhook (Formspree, a small Cloudflare Worker, or a self-hosted endpoint). Recipient types comments and submits; you receive them via email or Claude polls. No element-selector precision — just freeform notes.

**Solid middle ground.** Covers ~80% of "did you see my mockup?" workflows without needing a real backend.

### Tier 3 — Full multi-user annotation parity (weeks, or ~1–2 days via Agentation cloud)

Collaborators click elements, annotate, and you see the annotations land in your Claude session in real time. Requires: public-internet Agentation server (not localhost), auth, identity per annotation, push or polling back to your machine, hosted database.

**Shortcut:** Agentation has a hosted cloud at `agentation-mcp-cloud.vercel.app/api` with an API-key model. If their cloud supports shared sessions, the skill just needs to set `AGENTATION_API_KEY` + route the toolbar to their cloud instead of localhost. Worth scouting their cloud capabilities before any build work — if they have it, this is ~1–2 days; if not, it's real product engineering.

**Don't build this until Tier 1 has shipped.** Validate the read-only share use case first.

## Credits

- [Greg Dogum](https://github.com/dogum) — `dogum/html-artifacts`, the base skill (Apache 2.0).
- [Thariq Shihipar](https://thariqs.github.io/html-effectiveness/) — the original thesis on HTML effectiveness.
- [Benji Taylor](https://github.com/benjitaylor/agentation) — Agentation, the annotation toolkit (PolyForm Shield 1.0.0).
- Anthropic — Claude Code, the Playground plugin.

## License

Apache 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

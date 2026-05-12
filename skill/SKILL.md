---
name: effective-html
description: Produce a self-contained HTML artifact instead of a markdown document when the request benefits from spatial layout, color, real diagrams, interactivity, or a round-trip editor. Aggressively reach for HTML on requests phrased as "doc," "writeup," "plan," "spec," "report," "explainer," "summary," "comparison," "review," "PR description," "mockup," "diagram," "flowchart," "deck," "slides," "status update," "post-mortem," "incident report," "playground," or one-off "editor" or "tool" requests — even when the user doesn't say "HTML." Also trigger when the user asks Claude to "explain," "summarize," "compare," "explore options for," "brainstorm directions for," or "walk through" a non-trivial topic. Stay in markdown only for short conversational replies, code-only outputs, terminal-style command answers, and content that's genuinely just a few sentences. Honor the `/preview` slash command as an explicit force-HTML signal.
---

# HTML Artifact

This skill produces self-contained HTML artifacts when the deliverable would benefit from visual layout, interactivity, or shareability. It is based on [dogum/html-artifacts](https://github.com/dogum/html-artifacts) by Greg Dogum (Apache 2.0), extended with: a hard 95% interview rule, hybrid offer/explicit triggers, project-aware artifact paths, a global artifact index, the Playground-plugin routing decision, and an optional Agentation annotation loop.

---

## Hard rule: interview to ≥95% confidence first

**Before producing any HTML artifact for a non-trivial request, interview the user to ≥95% confidence about intent.** This rule is enforced by the skill itself and is independent of whatever sits in the user's `CLAUDE.md`.

What to probe for, conversationally (one or two questions per turn, not a batched form):

- Who's the audience? You, a teammate, leadership, an implementer, a designer?
- Static or interactive? A page they'll read, or controls they'll manipulate?
- What does "done" look like? Screenshot-ready? Iteratable? Round-trip back to text?
- Scope: one page, a tabbed view, or a folder of linked artifacts?
- Any existing visual style to match? (Pointer to a `frontend-design` skill or a design system file.)
- Anything they explicitly *don't* want?

**Skip the interview only when:** (a) the user said "just build it," "skip the interview," "no questions," or similar; (b) the request is a clearly-specified one-liner ("make a 3-column diff of these two files"); (c) the work is an obvious continuation of a recently-aligned artifact.

When you hit 95%, summarize the spec back in one or two sentences ("Building a static side-by-side comparison of options A and B for a teammate audience, single page, no annotations — sound right?") and then build. Do not build silently.

---

## Triggers

Three trigger flavors, in priority order:

1. **Explicit `/preview` command.** When the user types `/preview <anything>`, treat it as a hard request for an HTML artifact. The interview rule still applies — do not skip clarifying questions just because the trigger was explicit. Skip clarification only on the carve-outs above.

2. **Strong-signal phrasing.** Words and phrases from this skill's `description` field (plan, spec, report, mockup, deck, comparison, walk through, etc.) on non-trivial scope. Default to building HTML after the interview.

3. **Borderline offer.** When the answer *could* be HTML or markdown and the user didn't signal preference, briefly *offer*: "Want this as an interactive HTML page or a quick markdown summary?" Do not generate HTML without consent on borderline cases.

**Stay-silent rule.** During unrelated tasks (debugging, refactoring, terminal commands, code edits), do not offer HTML unless the answer *itself* is genuinely better as HTML. Don't nag. The skill is opt-in by content, not by interruption.

---

## When to reach for HTML

Reach for HTML when **any** of the following is true.

- **Comparison.** Two or more options/approaches/designs the reader needs to weigh. Side-by-side beats stacked.
- **Spatial information.** Diffs, call graphs, module maps, flowcharts, timelines, before/after — anything where position carries meaning.
- **Interaction matters.** Animations, easing curves, parameter tuning, state transitions — things the reader needs to *feel*, not read about.
- **Reference material.** A document the reader will navigate non-linearly: tabs, collapsible sections, glossary in the margin, jump links.
- **Color or hierarchy carries meaning.** Severity tags, status colors, syntax highlighting, design tokens.
- **One-off editor.** The reader needs to manipulate a thing (drag tickets, toggle flags, tune a prompt) and round-trip the result back to a prompt or commit.
- **The reader will share it.** A spec going to leadership, a PR writeup going to reviewers, a status report going to a team.
- **Length.** Anything longer than ~100 lines in markdown becomes hard to read. HTML's navigation and layout earn their keep past that threshold.

The heuristic: if the user is going to *do* something with the document — read it carefully, share it, refer back to it, hand it to an implementer, paste edits back in — make it HTML.

## When to stay in markdown

- Short conversational replies inside chat.
- Code-only outputs (a function, a config block, a one-liner).
- Terminal/command-flavored answers ("run this, then that").
- Quick three-bullet summaries the reader will scan once and discard.
- Files that need to be diffed in version control regularly.

---

## Routing: static artifact vs Playground plugin

Before drafting, decide which output format fits.

**Use the Playground plugin** when the artifact needs:
- Live user-tunable controls (sliders, dropdowns, prompt inputs) where state matters.
- A live preview that re-renders as the user adjusts inputs.
- A "playground" feel — the user is exploring a parameter space, not reading a page.

If the Playground plugin is installed (check `~/.claude/skills/effective-html/.config.json` → `playground_installed: true`), emit the artifact in Playground-compatible format and tell the user how to open it. If the plugin is not installed, fall back to a single-file HTML with inline JS for controls, and mention once that `/preview --install playground` would give a better experience.

**Use a single-file static HTML artifact** for everything else: diagrams, comparisons, reports, decks, diffs, one-off editors with self-contained state.

---

## Universal rules for every HTML artifact

Every artifact must satisfy all of these:

1. **Single self-contained `.html` file** (unless using the Playground plugin format). No build step, no bundler, no `npm install`. CSS in `<style>`, JS in `<script>`, images inline SVG or data URIs.
2. **Works offline.** No required network calls at view time.
3. **Mobile responsive.** Include `<meta name="viewport" content="width=device-width, initial-scale=1">`.
4. **Real layout, not stacked headers.** If the content is a comparison, lay it out in columns. If it's a timeline, draw a timeline.
5. **Readable on its own.** Title at the top, one-paragraph framing right below, then substance. Five-second test.
6. **Tasteful by default.** Legible body type, comfortable line length (60–75ch), generous spacing, restrained color. See `references/matching-your-style.md`. Resist the "everything is a card with a gradient" default-AI look.
7. **Editors export back to text.** Any artifact where the reader manipulates state must end with a "copy as markdown/JSON/prompt" button.

---

## Artifact location

**Project-aware.** Determine the save path before writing.

- If the current working directory is inside a git repo (`git rev-parse --is-inside-work-tree` succeeds): save to `./artifacts/claude-html/<kebab-slug>.html`. Create the directory if needed. This keeps the artifact alongside the project so it can be committed if desired.
- Otherwise: save to `~/.claude/artifacts/<YYYY-MM-DD>/<kebab-slug>.html`. Use today's date for the folder.

**Global index.** After every save, append an entry to `~/.claude/artifacts/index.html` (or create it from `templates/index.html.tmpl` if absent). Entry includes: timestamp, project name (cwd basename or "global"), artifact title, absolute path, one-line description.

**Auto-open.** After writing, run `open <file>` on macOS (or print the file path on other platforms). Always print the path to the user as well — don't rely on the browser open alone.

**Web of related files.** If the artifact is part of a set (explorations → mockups → plan), put them in a subfolder together.

---

## Agentation annotation integration (opt-in, selective)

Check `~/.claude/skills/effective-html/.config.json` for `agentation_installed: true`. If not installed, generate static HTML without the toolbar and — only on artifacts where annotation would have helped — mention once: "If you want to annotate this in the browser and have me iterate, run `~/.claude/skills/effective-html/install.sh --add agentation`."

If installed, **decide per-artifact whether to inject the toolbar.** Not every artifact wants Agentation. The toolbar adds visual chrome and only pays off when the user is going to iterate. Make the call before writing.

**Inject the toolbar when** the artifact is iterable:
- Design mockups, UI prototypes, design explorations
- Draft decks or draft documents the user will refine
- Anything labeled "v1," "draft," "wip," "first pass"
- Any time the user has explicitly asked for revisions in the same conversation
- One-off editors / interactive tools (the annotation layer doesn't conflict with the editor's own UI)

**Skip the toolbar when** the artifact is read-once or shareable-as-finished:
- Finished reports, post-mortems, incident timelines
- Static diagrams, flowcharts, architecture pictures
- Code-review writeups, PR descriptions, annotated diffs
- Status updates, summaries
- Anything the user said is going to a wider audience (leadership, team, reviewers)

When in doubt — and when the interview didn't already settle it — ask: "Is this a draft you'll iterate on, or a final you'll share? (affects whether I add the annotation toolbar)."

**When you inject the toolbar:**

1. **Auto-start the Agentation HTTP server** in the background if it isn't already running:
   ```
   pgrep -f "agentation-mcp server" >/dev/null || \
     (npx -y agentation-mcp server >/tmp/agentation.log 2>&1 &)
   ```
   The bare `server` form starts both the HTTP server on `localhost:4747` (which serves `toolbar.js` to the page) and the stdio MCP. The `--mcp-only` MCP registration does *not* run the HTTP server, so this background launch is required for the toolbar to load in the browser.
2. **Inject the snippet** from `templates/agentation-snippet.html` before `</body>`.
3. **Tell the user once, in chat:**
   > "Annotation server running on port 4747. Open the artifact, click anything you want changed, then tell me to iterate. Run `pkill -f agentation-mcp` when you're done."
4. **The feedback loop:** when the user says "iterate" / "apply the annotations" / similar, call `mcp__agentation__watch_annotations` (blocks until annotations arrive or timeout). Read the returned annotations (selectors + computed styles + user notes + thread). Regenerate the artifact, call `mcp__agentation__resolve` on each annotation, reopen. Loop until the user says done.

**Conversion path.** If you produced a static artifact and the user later says "make this annotatable" or "let me mark this up," re-emit the artifact with the toolbar injected and auto-start the server.

---

## Category index

Pick the matching reference file below before drafting. Each has the per-category pattern (layout, what's load-bearing, mistakes to avoid) plus a sketch.

| If the request is about… | Read… |
|---|---|
| Brainstorming options, side-by-side comparisons, implementation plans | `references/exploration-and-planning.md` |
| Annotated diffs, PR writeups, code review, module maps, "explain this code" | `references/code-review-and-pr.md` |
| Design systems, component sheets, mockups, prototyping animations | `references/design-and-prototypes.md` |
| Inline SVG figures, flowcharts, architecture diagrams | `references/diagrams-and-illustrations.md` |
| Status reports, incident timelines, post-mortems, concept explainers | `references/reports-and-research.md` |
| Slide decks, arrow-key presentations | `references/decks.md` |
| One-off custom editors: triage boards, flag toggles, prompt tuners | `references/custom-editors.md` |
| Matching the user's existing visual style or design system | `references/matching-your-style.md` |

If the request spans multiple categories, read all relevant references. They're short.

---

## Notes on cost, taste, and what this skill is not

**Cost.** HTML artifacts cost roughly 2–4× the tokens of a markdown equivalent. The skill errs toward HTML because reading experience and shareability win, but don't manufacture a use case where markdown would do.

**Taste.** Bad HTML is worse than good markdown. If the output would render as a wall of generic Tailwind cards with emoji headers, slow down. Read `references/matching-your-style.md`. Default to a calm typographic layout, not a busy "dashboard" look.

**What this skill is not.** It is not "always answer in HTML." For many of the things people ask agents to produce — plans, comparisons, reviews, explainers, editors — the markdown format actively obscures the content. HTML lifts that constraint. Where markdown is genuinely better, use markdown.

---

## Attribution

This skill builds on:
- [dogum/html-artifacts](https://github.com/dogum/html-artifacts) by Greg Dogum — original SKILL.md and category references (Apache 2.0).
- Thariq Shihipar's [HTML Effectiveness](https://thariqs.github.io/html-effectiveness/) gallery — the underlying thesis.
- [Agentation](https://github.com/benjitaylor/agentation) by Benji Taylor — optional annotation integration (PolyForm Shield 1.0.0, used as a separate tool, not redistributed).

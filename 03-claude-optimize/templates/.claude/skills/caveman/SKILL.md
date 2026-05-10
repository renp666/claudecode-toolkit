# Caveman Token Optimizer

A Claude Code skill that makes AI agents respond in compressed caveman-speak — cutting ~65% of output tokens on average (up to 87%) while keeping full technical accuracy. No pleasantries. No filler. Just answer.

Source: https://github.com/juliusbrussee/caveman

## What It Does

Caveman mode strips:

- Pleasantries: "Sure, I'd be happy to help!" → gone
- Hedging: "It might be worth considering" → gone
- Articles (a, an, the) → gone
- Verbose transitions → gone

Caveman keeps:

- All code blocks (written normally)
- Technical terms (exact: `useMemo`, `polymorphism`, `middleware`)
- Error messages (quoted exactly)
- Git commits and PR descriptions (normal)
- Security warnings and safety-critical information (never compressed)

**Same fix. 75% less word. Brain still big.**

## Usage — Trigger Commands

### Activate

```
/caveman            # enable default (full) caveman mode
/caveman lite       # professional brevity, grammar intact
/caveman full       # default — drop articles, use fragments
/caveman ultra      # maximum compression, telegraphic
```

### Natural language triggers

Any of these phrases activate caveman mode:

- "talk like caveman"
- "caveman mode"
- "less tokens please"
- "be concise"

### Disable

```
/caveman off
# or say: "stop caveman" / "normal mode"
```

Level sticks until changed or session ends.

## Intensity Levels

| Level | Trigger | Style | Example |
|---|---|---|---|
| **Lite** | `/caveman lite` | Drop filler, keep grammar | "Component re-renders because inline object prop creates new reference each cycle. Wrap in `useMemo`." |
| **Full** | `/caveman full` | Drop articles, use fragments | "New object ref each render. Inline prop = new ref = re-render. Wrap in `useMemo`." |
| **Ultra** | `/caveman ultra` | Telegraphic, abbreviate everything | "Inline obj prop → new ref → re-render. `useMemo`." |

## Additional Skills

- `/caveman-commit` — Generates commit messages under 50 chars, focused on why not what
- `/caveman-review` — Forces short, one-line review comments with exact line numbers
- `/caveman:compress <filepath>` — Rewrites a file (like CLAUDE.md) into shorter version
- `/caveman-help` — Quick-reference cheat sheet of every mode, skill, and command

## Benchmark Results

| Task | Normal | Caveman | Saved |
|---|---|---|---|
| React re-render bug | 1180 | 159 | 87% |
| Auth middleware fix | 704 | 121 | 83% |
| PostgreSQL pool setup | 2347 | 380 | 84% |
| Git rebase vs merge | 702 | 292 | 58% |
| Async/await refactor | 387 | 301 | 22% |
| Docker multi-stage build | 1042 | 290 | 72% |
| **Average** | **1214** | **294** | **65%** |

**Important:** Caveman only affects output tokens. Thinking/reasoning tokens are untouched. Caveman make mouth smaller, not brain.

## Installation

```bash
# Claude Code (recommended)
npx skills add JuliusBrussee/caveman

# Or manual: place this SKILL.md in <project>/.claude/skills/caveman/
```

## When NOT to Use Caveman

- Security audits (need full detail for traceability)
- Client-facing documentation (professional tone required)
- Complex architectural discussions (nuance matters)
- Legal/compliance reviews (precision over brevity)

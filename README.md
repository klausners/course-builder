# course-builder

> A Claude Code plugin that researches real articles and YouTube videos, cross-references facts, and synthesizes structured study courses with narrative arcs -- not link roundups.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-plugin-blueviolet)](https://code.claude.com/docs/en/plugins)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## The problem

AI course generators prompt an LLM and call it a day. Deep research agents produce reports, not courses. No existing tool does both: **read real articles AND produce structured educational content.**

course-builder fills that gap.

```
You: /course-builder:course product discovery for PMs

course-builder:
  → asks up to 4 scoping questions (audience, success criteria, scope, depth)
  → searches 15-25 real articles and YouTube videos
  → reads articles and extracts video transcripts
  → cross-references facts across sources
  → synthesizes into a 10-lesson course with narrative arc
  → extracts actionable frameworks per lesson
  → hunts for unexplored opportunities via innovation scout
  → delivers a self-contained .md file (and PDF) you can learn from start to finish
```

## How it's different

| | course-builder | AI course generators (Coursebox, CourseMagic, etc.) | Deep research agents (GPT Researcher, etc.) |
|---|---|---|---|
| Reads real articles + YouTube transcripts | Yes (10-25+) | No -- prompts LLM directly | Yes |
| Structured course output | Modules, lessons, narrative arc | Shallow outlines | Reports only |
| Fact validation | Quorum: 3+ sources = high confidence | None | Some |
| Actionable frameworks | Every lesson | Rarely | No |
| Source attribution | Per lesson, with links | Generic or none | Per report |
| Innovation analysis | Dedicated scout agent | No | No |
| Incremental mode | Add modules to existing courses | No | No |
| Learns your preferences | Persistent agent memory | No | No |
| Research transparency | Full metadata (sources read, failures, quorum stats) | None | Partial |

## Installation

### As a plugin (recommended)

In Claude Code:

```
/plugin install course-builder --marketplace klausners/course-builder
```

Or in two steps (also works on older versions):

```
/plugin marketplace add klausners/course-builder
/plugin install course-builder@course-builder
```

Updates come through `/plugin` like any other marketplace plugin.

### Manually

```bash
git clone https://github.com/klausners/course-builder.git
cp course-builder/agents/*.md ~/.claude/agents/
mkdir -p ~/.claude/skills && cp -r course-builder/skills/course ~/.claude/skills/
```

With a manual install the skill is `/course` instead of `/course-builder:course`, and the agent calls the YouTube library directly through `uvx` instead of the bundled script.

### YouTube support (optional)

Transcripts are fetched with [youtube-transcript-api](https://github.com/jdepoix/youtube-transcript-api). Nothing to install if you have [uv](https://docs.astral.sh/uv/) (`uvx` runs it in an isolated environment) or `pipx`. Otherwise:

```bash
pip3 install --user -r course-builder/requirements.txt
```

## Quick start

```
/course-builder:course product discovery for PMs
```

Or just ask in plain language -- Claude picks up the skill on its own:

```
Build a course on product discovery for PMs
```

The skill asks you up to 4 clarifying questions (audience, success criteria, scope, depth), then runs the full pipeline.

### More examples

```
/course-builder:course Kubernetes networking for backend engineers deep
```

```
Build a quick course on prompt engineering for designers
```

```
Add a module on security to my existing APIs course at ~/Documents/course-apis.md
```

## How it works

### Lead + three agents

```
[/course skill: scope + brief]
        ↓
[course-builder] ──→ [source-reader ×N, in parallel]
        ↓
[innovation-scout]
        ↓
[skill: integrate + export + deliver]
```

1. The **course skill** runs in your main conversation. It asks the scoping questions (subagents can't talk to you), writes a brief, and orchestrates the run
2. **course-builder** does the thinking: search, source selection, quorum validation, synthesis, writing, framework extraction. It ends with a structured handoff
3. **source-reader** agents do the reading. course-builder sends them batches of 3-4 sources in parallel, and each returns a structured log per source (concepts, frameworks, figures, verbatim quotes). course-builder re-checks the claims a lesson rests on against the original
4. **innovation-scout** receives the handoff and hunts for what's MISSING: unexplored opportunities, gaps in current practice, cross-domain applications
5. The skill integrates the innovation chapter, exports the PDF, and delivers the summary

### Model strategy

| Component | Model | Effort | Why |
|---|---|---|---|
| course skill | your session's model | default | Orchestration only: questions, merging, pandoc |
| course-builder | Opus | high | Synthesis and writing define the course's quality |
| source-reader | Haiku (Sonnet in Deep mode) | medium | Reading is the bulk of the tokens; structured extraction doesn't need the top model. Deep mode pays for extra nuance |
| innovation-scout | Opus | high | Small token volume, judgment-heavy: novelty and feasibility calls benefit most from the stronger model |

Want a faster or cheaper run? Say so in your request ("use Sonnet") and the skill launches course-builder on Sonnet.

### Research pipeline

```
Skill    Clarify scope (audience, success criteria, scope, depth) → brief
Step 0   Read memory and user context (voice profile, preferences)
Step 0.5 Detect mode (standard or incremental)
Step 1   Read the brief, record assumptions for anything missing
Step 2   Web + YouTube search: cast a wide net (8-40 sources depending on depth)
Step 3   Parallel source-readers read articles + YouTube transcripts; verify key claims
Step 3.5 Recursive sub-research per module (deep mode only)
Step 4   Synthesize: map concepts, eliminate redundancy, build narrative arc
Step 5   Write lessons (hook → content → frameworks → takeaways → sources)
Step 6   Build framework kit table with confidence levels
Step 7   Build complete source table with links
Step 7.5 Generate research metadata
Step 8   Save .md, update memory, return handoff
Scout    Innovation chapter from the handoff
Skill    Integrate chapter, export PDF, deliver summary
```

### Research depth levels

| Level | Web searches | YouTube searches | Sources | Articles read | Lessons | Best for |
|-------|-------------|-----------------|---------|---------------|---------|----------|
| **Quick** | 3-4 | 1 | 8-12 | 6-8 | 6-8 | Narrow topics, time-sensitive needs |
| **Standard** (default) | 4-6 | 1-2 | 15-25 | 10-15 | 8-12 | Most courses |
| **Deep** | 6-10 | 2-3 | 25-40 | 15-25 | 12-18 | Reference-grade material |

Deep mode triggers **recursive sub-research**: after the initial pass, the agent identifies knowledge gaps per module and runs targeted searches to fill them.

### Fact validation (quorum system)

Every concept is tracked across sources:

- **3+ independent sources** → high confidence, stated as fact
- **1-2 sources** → medium confidence, hedged attribution ("According to [Author]...")
- The Framework Kit table shows confidence levels for each deliverable
- Single-source claims are never presented as universal truth

### Source diversity enforcement

The agent checks its research pool for:

- At least 3 different author perspectives (not all from one person/company)
- At least 1 contrarian or alternative viewpoint
- At least 2 practical/implementation-focused sources (not all theory)

Missing any of these triggers additional targeted searches automatically.

### Memory across courses

Both agents use Claude Code's persistent [agent memory](https://code.claude.com/docs/en/sub-agents) (`memory: user`). Over time they remember:

- Your language, writing style, voice profile and usual audience
- Domains that always fail (paywalls, 403s) so they're skipped up front, and domains that produced great material
- Courses already built (topic, path, date), which helps incremental mode
- Opportunities the scout already proposed, so it doesn't repeat itself

Memory requires auto memory to be on (it is by default).

## Output structure

Every course includes:

| Section | Description |
|---------|-------------|
| **Modules and lessons** | Narrative progression from foundations to advanced |
| **Innovation chapter** | Unexplored opportunities from the scout agent |
| **Framework Kit** | Table of all actionable frameworks with lesson references and confidence |
| **Source table** | Every article cited, per lesson, with links |
| **Research metadata** | Depth used, searches performed, articles read, quorum stats, failures |

Optional: **PDF export** via pandoc with Typst (or WeasyPrint), automatic for Deep courses or on request.

## Customization

The plugin is plain Markdown -- no build step. Fork it and edit:

| What to change | Where |
|----------------|-------|
| Scoping questions, output path, PDF export | `skills/course/SKILL.md` |
| Lesson structure template | Step 5 in `agents/course-builder.md` |
| Research depth parameters | Step 2 in `agents/course-builder.md` |
| Quality criteria checklist | End of `agents/course-builder.md` |
| What gets extracted from each source | Output template in `agents/source-reader.md` |
| Model and effort per agent | `model` / `effort` in each agent's frontmatter |
| Innovation chapter format | Step 4 in `agents/innovation-scout.md` |

To try your changes without installing: `claude --plugin-dir ./course-builder`.

## Limitations

- **Depends on web access.** The agent needs to fetch real articles. Sites behind paywalls, login walls, or aggressive bot protection (403s) will be skipped. The agent retries with alternative sources, but some niche topics may have limited freely accessible content.
- **Quality scales with source quality.** If the available articles on a topic are shallow, the course will reflect that. Deep mode with recursive research mitigates this but can't create depth that doesn't exist online.
- **Long generation time.** A standard course takes 5-15 minutes. Deep courses can take 20-30+ minutes. This is the cost of actually reading articles instead of prompting an LLM.
- **No multimedia.** Outputs Markdown (and optionally PDF). Does not generate slides, videos, quizzes, or interactive content.
- **Claude Code only.** The plugin runs inside Claude Code (terminal, desktop app, IDE extensions). It is not a standalone CLI tool or web app.
- **Token usage.** Reading 10-25 full articles and writing a complete course consumes significant tokens, Deep mode especially. Reading runs on Haiku to keep this down; synthesis and the innovation chapter run on Opus.
- **Readers summarize.** course-builder works from the readers' structured logs, not the raw text. It re-reads the sources behind claims a lesson depends on, but nuance in sources it doesn't re-read can be lost.
- **YouTube blocks cloud IPs.** On cloud machines, VPSs and remote sessions YouTube usually refuses transcript requests. The agent detects this on the first video, skips YouTube for the rest of the run, and notes it in the research metadata. Run locally to include videos.
- **YouTube captions required.** Videos without auto-generated or manual captions are skipped. Age-restricted videos cannot be accessed.
- **Transcript quality varies.** Auto-generated captions may contain errors. The synthesis step cross-references across sources, so a poorly transcribed video contributes less but doesn't corrupt the course.

## Requirements

- [Claude Code](https://code.claude.com/docs) with a Claude subscription (Pro, Max, Team, Enterprise) or an API key
- Optional: [uv](https://docs.astral.sh/uv/) or `pipx` for YouTube transcripts
- Optional: `pandoc` + [Typst](https://typst.app) for PDF export

```bash
# macOS
brew install pandoc typst uv

# Ubuntu/Debian
sudo apt install pandoc
# Typst: download from https://github.com/typst/typst/releases (or: cargo install --locked typst-cli)
# uv: curl -LsSf https://astral.sh/uv/install.sh | sh
```

wkhtmltopdf is no longer supported: the project was archived in 2023 and Homebrew disabled it in December 2024.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Ideas for contributions: new output formats, additional quality checks, support for other research sources (e.g., academic papers via Semantic Scholar), localization of lesson templates.

## License

[MIT](LICENSE)

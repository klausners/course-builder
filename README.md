# course-builder

> AI agents for Claude Code that research real articles and YouTube videos, cross-reference facts, and synthesize structured study courses with narrative arcs -- not link roundups.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-agent-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## The problem

AI course generators prompt an LLM and call it a day. Deep research agents produce reports, not courses. No existing tool does both: **read real articles AND produce structured educational content.**

course-builder fills that gap.

```
You: "Build a course on product discovery for PMs"

course-builder:
  → searches 15-25 real articles and YouTube videos
  → reads articles and extracts video transcripts
  → cross-references facts across sources
  → synthesizes into a 10-lesson course with narrative arc
  → extracts actionable frameworks per lesson
  → hunts for unexplored opportunities via innovation scout
  → delivers a self-contained .md file you can learn from start to finish
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
| Research transparency | Full metadata (sources read, failures, quorum stats) | None | Partial |

## Installation

```bash
git clone https://github.com/klausners/course-builder.git
cp course-builder/.claude/agents/*.md ~/.claude/agents/

# Optional: pre-install YouTube transcript support (auto-installed on first use if skipped)
pip3 install -r course-builder/requirements.txt
```

Done. Both agents (`course-builder` and `innovation-scout`) are now available in Claude Code.

## Quick start

Open Claude Code and ask:

```
Build a course on product discovery for PMs
```

The agent will ask you up to 4 clarifying questions (audience, depth, scope, success criteria), then run the full pipeline autonomously.

### More examples

```
Create a deep course on Kubernetes networking for backend engineers
```

```
Build a quick course on prompt engineering for designers
```

```
Add a module on security to my existing APIs course at ~/Documents/course-apis.md
```

## How it works

### Two-agent team workflow

```
[course-builder]  →  [innovation-scout]  →  [Team lead: integrate + deliver]
```

1. **course-builder** does the heavy lifting: web search, full article reads, synthesis, writing, framework extraction
2. **innovation-scout** receives the course context and hunts for what's MISSING: unexplored opportunities, gaps in current practice, cross-domain applications
3. **Team lead** (Claude Code itself) orchestrates the workflow, integrates the innovation chapter, and delivers the final file

### Research pipeline

```
Step 0   Read user context (voice profile, preferences)
Step 0.5 Detect mode (standard or incremental)
Step 1   Clarify scope (audience, depth, success criteria)
Step 2   Web + YouTube search: cast a wide net (8-40 sources depending on depth)
Step 3   Read articles + extract YouTube transcripts (not just snippets)
Step 3.5 Recursive sub-research per module (deep mode only)
Step 4   Synthesize: map concepts, eliminate redundancy, build narrative arc
Step 5   Write lessons (hook → content → frameworks → takeaways → sources)
Step 6   Build framework kit table with confidence levels
Step 7   Build complete source table with links
Step 7.5 Generate research metadata
Step 7.7 Integrate innovation chapter (if running as team)
Step 8   Save .md, optional PDF export, deliver summary
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

## Output structure

Every course includes:

| Section | Description |
|---------|-------------|
| **Modules and lessons** | Narrative progression from foundations to advanced |
| **Framework Kit** | Table of all actionable frameworks with lesson references and confidence |
| **Source table** | Every article cited, per lesson, with links |
| **Research metadata** | Depth used, searches performed, articles read, quorum stats, failures |
| **Innovation chapter** | Unexplored opportunities from the scout agent |

Optional: **PDF export** via pandoc (runs automatically if installed).

## Customization

The agents are plain `.md` files -- no build step, no dependencies. Edit them directly:

| What to change | Where |
|----------------|-------|
| Lesson structure template | Step 5 in `course-builder.md` |
| Research depth parameters | Step 2 in `course-builder.md` |
| Quality criteria checklist | End of `course-builder.md` |
| Default save location | Step 8 in `course-builder.md` |
| Voice profile path | Step 0 in `course-builder.md` |
| Innovation chapter format | Step 4 in `innovation-scout.md` |

## Limitations

- **Depends on web access.** The agent needs to fetch real articles. Sites behind paywalls, login walls, or aggressive bot protection (403s) will be skipped. The agent retries with alternative sources, but some niche topics may have limited freely accessible content.
- **Quality scales with source quality.** If the available articles on a topic are shallow, the course will reflect that. Deep mode with recursive research mitigates this but can't create depth that doesn't exist online.
- **Long generation time.** A standard course takes 5-15 minutes. Deep courses can take 20-30+ minutes. This is the cost of actually reading articles instead of prompting an LLM.
- **No multimedia.** Outputs Markdown (and optionally PDF). Does not generate slides, videos, quizzes, or interactive content.
- **Claude Code only.** These agents run inside Claude Code. They are not standalone CLI tools or web apps.
- **Token usage.** Reading 10-25 full articles and writing a complete course consumes significant tokens. Deep mode especially.
- **YouTube captions required.** Videos without auto-generated or manual captions are skipped. Age-restricted videos cannot be accessed.
- **Transcript quality varies.** Auto-generated captions may contain errors. The synthesis step cross-references across sources, so a poorly transcribed video contributes less but doesn't corrupt the course.
- **No persistent memory across courses.** Each course build is independent. The agent doesn't learn from previously built courses (though incremental mode can extend existing ones).

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI)
- A Claude API key with access to Sonnet or Opus
- Optional: `pandoc` + `wkhtmltopdf` for PDF export
- Optional: `youtube-transcript-api` for YouTube research (auto-installed on first use)

```bash
# macOS
brew install pandoc wkhtmltopdf

# Ubuntu/Debian
sudo apt install pandoc wkhtmltopdf
```

## Contributing

Contributions welcome. The agents are plain Markdown files, so the bar to contribute is low:

1. Fork the repo
2. Edit the agent `.md` files
3. Test by copying to `~/.claude/agents/` and running a course build
4. Open a PR describing what you changed and why

Ideas for contributions: new output formats, additional quality checks, support for other research sources (e.g., academic papers via Semantic Scholar), localization of lesson templates.

## License

[MIT](LICENSE)

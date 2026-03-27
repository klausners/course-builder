# course-builder

Research-driven course generator for Claude Code. Reads real articles. Writes real courses.

## What this is

A pair of Claude Code agents that build comprehensive study courses on any topic. Unlike AI course generators that just prompt an LLM, this agent:

1. **Searches** for 8-40 real articles (configurable depth)
2. **Reads them in full** via web fetch
3. **Cross-references facts** across sources (quorum validation)
4. **Synthesizes** into a coherent narrative arc from beginner to advanced
5. **Produces actionable frameworks** in every lesson
6. **Attributes every claim** to its source

The result is a self-contained `.md` course that can teach you the topic without clicking a single link.

## How it's different

| | course-builder | Typical AI course generators | Deep research agents |
|---|---|---|---|
| Reads real articles | Yes (10-25) | No -- prompts LLM directly | Yes |
| Structured course output | Yes -- modules, lessons, arc | Yes -- but shallow | No -- reports only |
| Fact validation | Quorum (3+ sources) | None | Some |
| Actionable frameworks | Every lesson | Rarely | No |
| Source attribution | Per lesson | Generic | Per report |
| Innovation analysis | Yes (scout agent) | No | No |
| Incremental mode | Yes -- add to existing courses | No | No |

## Installation

```bash
# Clone to your home directory (or anywhere)
git clone https://github.com/klausners/course-builder.git

# Copy agents to your Claude Code config
cp course-builder/.claude/agents/*.md ~/.claude/agents/
```

That's it. The agents are now available in Claude Code.

## Usage

In Claude Code, just ask:

```
Build a course on product discovery for PMs
```

```
Create a deep course on Kubernetes networking for backend engineers
```

```
Add a module on security to my existing APIs course at ~/Documents/course-apis.md
```

The system will:
1. Ask you clarifying questions (audience, depth, success criteria)
2. Research the topic (web search + full article reads)
3. Write the course with narrative arc and frameworks
4. Run the innovation scout to find unexplored opportunities
5. Save to `~/Documents/` and open in VS Code

### Research depth levels

| Level | Sources | Lessons | Best for |
|-------|---------|---------|----------|
| Quick | 8-12 | 6-8 | Narrow topics, time-sensitive |
| Standard (default) | 15-25 | 8-12 | Most courses |
| Deep | 25-40 | 12-18 | Reference-grade material |

Deep mode includes **recursive sub-research**: after the initial pass, it identifies knowledge gaps per module and runs targeted searches to fill them.

## How it works

### Two-agent team

```
[course-builder]  →  [innovation-scout]  →  [Team lead: integrate + deliver]
```

**course-builder** does the heavy lifting: research, synthesis, writing, framework extraction.

**innovation-scout** receives the course context and hunts for what's MISSING: unexplored opportunities, gaps in current practice, cross-domain applications. Produces an extra chapter.

The team lead (Claude Code itself) orchestrates the workflow, integrates the innovation chapter, and delivers the final file.

### Fact validation

Every concept gets tracked across sources:
- **3+ sources confirm it** → high confidence, stated as fact
- **1-2 sources** → medium confidence, attributed ("According to [Author]...")
- The Framework Kit table shows confidence levels for each deliverable

### Source diversity

The agent enforces diversity in its research:
- At least 3 different author perspectives
- At least 1 contrarian or alternative viewpoint
- At least 2 practical/implementation-focused sources

If gaps are detected, additional searches are triggered automatically.

## Output

Every course includes:

- **Modules and lessons** with narrative progression
- **Framework Kit** -- table of all actionable frameworks with lesson references and confidence levels
- **Complete source table** -- every article cited, per lesson, with links
- **Research metadata** -- transparency on depth, sources read, quorum stats, failures
- **Innovation chapter** -- unexplored opportunities from the scout agent

Optional: **PDF export** via pandoc (the agent will run it if pandoc is installed).

## Customization

The agents are plain `.md` files. You can:

- Change the lesson structure template (Step 5)
- Adjust research depth parameters (Step 2)
- Modify the quality criteria checklist
- Change the default save location
- Add your own voice profile path in Step 0

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (CLI)
- A Claude API key with access to Sonnet or Opus
- Optional: `pandoc` + `wkhtmltopdf` for PDF export (`brew install pandoc wkhtmltopdf` on macOS)

## License

MIT

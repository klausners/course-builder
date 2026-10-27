# Changelog

## 2.0.0 -- 2026-10-27

Repackaged as a Claude Code plugin. **Breaking:** the agents moved from `.claude/agents/` to `agents/`, and installation is now through `/plugin`. If you installed 1.x by copying files, see [Upgrading from 1.x](README.md#upgrading-from-1x).

### Added
- Plugin manifest and marketplace (`.claude-plugin/`): `/plugin install course-builder --marketplace klausners/course-builder`
- `course` skill (`/course-builder:course`): asks the scoping questions, writes the brief, runs the agents, merges the innovation chapter, exports the PDF
- `source-reader` agent (Haiku; Sonnet in Deep mode): reads batches of 3-4 sources in parallel and returns structured logs, so course-builder keeps raw text out of its context
- Persistent memory actually used by course-builder and innovation-scout: preferences, failing domains, past courses, opportunities already proposed
- course-builder verifies the claims a lesson rests on against the original source
- Structured `HANDOFF` from course-builder to the scout and the skill
- `CONTRIBUTING.md`, this changelog

### Changed
- Models: course-builder on Opus (was Sonnet), innovation-scout on Opus (was Sonnet), both at high effort
- Agent frontmatter: tool allowlists, `effort`, `maxTurns`, `color`; short descriptions (about 477 always-on tokens per session for the whole plugin)
- PDF export uses pandoc + Typst, with WeasyPrint as fallback
- `youtube-transcript.sh` accepts full URLs and language codes, runs through `uvx`/`pipx` instead of `pip install`, and exits with 2 when YouTube blocks the IP so the run stops trying videos
- Docs point to code.claude.com

### Fixed
- Scoping questions never reached the user: subagents can't use `AskUserQuestion`, so they now live in the skill
- YouTube script path was hardcoded to `~/course-builder/scripts/`
- Videos without an English transcript always failed (the CLI only tries `en` by default)
- `pip install` into the system Python fails on Homebrew and recent Debian/Ubuntu (PEP 668)

### Removed
- wkhtmltopdf support (discontinued upstream, disabled in Homebrew since December 2024)

## 1.1 -- 2026-03-30

- YouTube transcript research (`scripts/youtube-transcript.sh`)

## 1.0 -- 2026-03-27

- Initial release: course-builder and innovation-scout agents

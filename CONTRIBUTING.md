# Contributing

Contributions are welcome. The plugin is plain Markdown plus one shell script, so the bar is low.

## Layout

```
.claude-plugin/plugin.json       plugin manifest
.claude-plugin/marketplace.json  marketplace catalog (this repo is its own marketplace)
skills/course/SKILL.md           orchestration: scoping questions, brief, integration, PDF
agents/course-builder.md         research + writing agent
agents/source-reader.md          reads a batch of sources, returns structured logs
agents/innovation-scout.md       innovation chapter agent
scripts/youtube-transcript.sh    YouTube transcript helper (exit 0 ok / 1 skip video / 2 YouTube unavailable)
```

## Workflow

1. Fork the repo and create a branch
2. Edit the files
3. Validate: `claude plugin validate .`
4. Test without installing: `claude --plugin-dir .`, then run `/course-builder:course <a small topic> quick`
5. If you changed the script: `bash -n scripts/youtube-transcript.sh`, and run it on a video with and without captions. Test from your own machine: YouTube blocks most cloud IPs, so a cloud run only exercises the exit-2 path
6. Bump `version` in `.claude-plugin/plugin.json` when the change should reach installed users (installed copies are cached per version), and add an entry to `CHANGELOG.md`
7. Open a PR describing what you changed and why, ideally with an excerpt of a course generated with your change

## Guidelines

- Subagents can't ask the user questions. Anything that needs user input belongs in the skill, which passes it to the agents in the brief.
- Refer to bundled files through `${CLAUDE_PLUGIN_ROOT}`, never a fixed path.
- Keep agent and skill descriptions short: they are loaded into every session where the plugin is enabled. `claude plugin details course-builder` shows the always-on token cost.
- Model choices are deliberate (see "Model strategy" in the README). If you change one, say why in the PR.

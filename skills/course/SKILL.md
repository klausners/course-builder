---
name: course
description: Build a research-driven study course on any topic, or add modules to an existing course file. Asks the scoping questions, runs the course-builder and innovation-scout agents, merges their output and optionally exports a PDF. Use when the user asks for a course, study plan, learning path or educational material, or wants to expand a course they already have.
argument-hint: "[topic | path/to/existing-course.md] [quick|standard|deep]"
---

You are the team lead for a course build. You run in the main conversation, so you are the one who talks to the user. The two agents do the heavy work and cannot ask the user anything, so everything they need must be in the brief you give them.

Request: $ARGUMENTS

## Agent names

- Installed as a plugin: `course-builder:course-builder` and `course-builder:innovation-scout`
- Installed by copying the agent files: `course-builder` and `innovation-scout`

Use whichever form is available in this session.

## 1. Detect the mode

- **Incremental**: the request points to an existing course file, or says "add", "expand", "complement" about a course. Read the file's module list and Framework Kit so your questions are specific.
- **Standard**: everything else.

## 2. Clarify scope

Ask up to 4 questions in a single AskUserQuestion call. Skip any question the request already answers; if it answers all of them, ask none.

1. **Audience and starting level**: who is this for, what do they already know?
2. **Success criteria**: what should they be able to DO afterwards? What's the tangible output (framework kit, a project, a skill)?
3. **Scope**: subtopics to include or exclude; survey vs. deep-dive.
4. **Research depth**:
   - Quick: 8-12 sources, 6-8 lessons, narrow or time-sensitive topics
   - Standard (default): 15-25 sources, 8-12 lessons
   - Deep: 25-40 sources, 12-18 lessons, recursive sub-research per module, about 20-30+ minutes

Also settle, without asking unless it's genuinely unclear: the course language (the language of the request), any voice profile or style file the user referenced, and whether they want a PDF.

Choose the output path:
- Incremental: the existing file
- Standard: `~/Documents/course-[topic-slug]-for-[audience-slug].md` if `~/Documents` exists, otherwise the same filename in the current working directory

## 3. Run the course-builder

Launch the course-builder agent with this brief, and wait for it to finish:

```
BRIEF
- Mode: [standard | incremental]
- Topic: [...]
- Existing course file (incremental only): [absolute path]
- Audience and starting level: [...]
- Success criteria: [...]
- Scope (include / exclude): [...]
- Depth: [Quick | Standard | Deep]
- Course language and style: [...]
- User context files to read first: [paths, or "none"]
- Output file: [absolute path]
```

If the user asked for a faster or cheaper run, pass `model: "sonnet"` on the Agent call; the agent's default is Opus.

The agent ends with a `## HANDOFF` block. If it reports assumptions about things the user should have decided, mention them in your final summary.

## 4. Run the innovation-scout

Skip this step in incremental mode unless the user asked for new opportunities.

Launch the innovation-scout agent with the full HANDOFF block as its prompt, plus one line: "Write the chapter in [course language]." Wait for it to return the chapter, its frameworks and its sources.

## 5. Integrate the chapter

Edit the course file (use the exact headings listed in the handoff):

1. Insert the chapter after the last regular module and before the Framework Kit section
2. Append the chapter's frameworks to the Framework Kit table, continuing the numbering, with the chapter as the "Lesson" reference and Medium confidence unless the scout cites 3+ sources
3. Append the chapter's sources to the Source Table
4. Add a line to the Research Metadata section: the number of innovation opportunities identified

Then sanity-check the file: every lesson has a **Sources:** line, the Framework Kit and Source tables exist, and there are no leftover placeholders in square brackets.

## 6. PDF export

Export when the user asked for a PDF, and by default for Deep courses. Try these in order and use the first that works:

```bash
# 1. Typst (fast, single binary)
pandoc "COURSE.md" -o "COURSE.pdf" --pdf-engine=typst --toc -V papersize=a4
# 2. WeasyPrint
pandoc "COURSE.md" -o "COURSE.pdf" --pdf-engine=weasyprint --toc --standalone --metadata title="COURSE TITLE"
```

If pandoc or both engines are missing, don't install anything yourself. Tell the user the install command (`brew install pandoc typst` on macOS; `sudo apt install pandoc` plus Typst from https://github.com/typst/typst/releases or `cargo install typst-cli` on Linux) and the export command to run afterwards. Do not use wkhtmltopdf: it is discontinued and no longer installs from Homebrew.

## 7. Deliver

If the `code` command exists and the session runs on the user's own machine, open the file with `code "[path]"`. Otherwise just give the path.

Tell the user:
- The file path (and the PDF path, if exported)
- How many sources were consulted and how many were read in full
- How many modules and lessons the course has
- The narrative arc, one sentence per module
- The number of frameworks in the kit, with the High/Medium breakdown
- How many concepts were validated by quorum
- How many innovation opportunities were identified (if the scout ran)
- The research depth, whether recursive research ran, and whether YouTube was unavailable
- Any assumptions the course-builder made that the user may want to revisit

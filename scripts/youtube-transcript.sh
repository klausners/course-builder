#!/usr/bin/env bash
set -euo pipefail

# youtube-transcript.sh -- Extract YouTube video transcript as plain text
# Usage: bash scripts/youtube-transcript.sh VIDEO_ID
# Exit 0 + stdout transcript on success, exit 1 + stderr message on failure

VIDEO_ID="${1:-}"

if [ -z "$VIDEO_ID" ]; then
  echo "Usage: youtube-transcript.sh VIDEO_ID" >&2
  exit 1
fi

# Auto-install dependency if missing
if ! python3 -c "import youtube_transcript_api" 2>/dev/null; then
  echo "Installing youtube-transcript-api..." >&2
  pip3 install youtube-transcript-api >&2
fi

# Extract transcript, capturing both stdout and stderr
OUTPUT=$(python3 -W ignore -m youtube_transcript_api "$VIDEO_ID" --format text 2>&1) || true

# The CLI prints errors to stdout/stderr but may exit 0 on failure
if echo "$OUTPUT" | grep -q "Could not retrieve a transcript"; then
  echo "$OUTPUT" >&2
  exit 1
fi

echo "$OUTPUT"

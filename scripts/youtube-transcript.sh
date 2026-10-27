#!/usr/bin/env bash
set -euo pipefail

# youtube-transcript.sh -- Extract a YouTube video transcript as plain text
# Usage: bash scripts/youtube-transcript.sh VIDEO_URL_OR_ID [LANG ...]
#   LANG: language codes in priority order (default: en), e.g. "pt en"
# Exit codes:
#   0  transcript on stdout
#   1  this video has no usable transcript (skip it, try another source)
#   2  YouTube is unreachable for the whole run (IP blocked, or no Python
#      runner available) -- stop trying videos

INPUT="${1:-}"

if [ -z "$INPUT" ]; then
  echo "Usage: youtube-transcript.sh VIDEO_URL_OR_ID [LANG ...]" >&2
  exit 1
fi
shift
LANGS=("$@")
[ ${#LANGS[@]} -eq 0 ] && LANGS=(en)

# Accept full URLs (watch?v=, youtu.be/, shorts/, embed/, live/) or a bare ID
VIDEO_ID="$INPUT"
case "$INPUT" in
  *youtu*)
    VIDEO_ID=$(printf '%s' "$INPUT" | sed -E \
      -e 's#.*[?&]v=([A-Za-z0-9_-]{11}).*#\1#' \
      -e 's#.*youtu\.be/([A-Za-z0-9_-]{11}).*#\1#' \
      -e 's#.*/(shorts|embed|live)/([A-Za-z0-9_-]{11}).*#\2#')
    ;;
esac

if ! printf '%s' "$VIDEO_ID" | grep -Eq '^[A-Za-z0-9_-]{11}$'; then
  echo "Could not extract a video ID from: $INPUT" >&2
  exit 1
fi

# Pick a runner without touching the system Python: pip installs into it are
# refused on Homebrew Python and recent Debian/Ubuntu (PEP 668).
if command -v uvx >/dev/null 2>&1; then
  RUN=(uvx --quiet --from youtube-transcript-api youtube_transcript_api)
elif python3 -c "import youtube_transcript_api" 2>/dev/null; then
  RUN=(python3 -W ignore -m youtube_transcript_api)
elif command -v pipx >/dev/null 2>&1; then
  RUN=(pipx run --spec youtube-transcript-api youtube_transcript_api)
else
  echo "youtube-transcript-api is not available. Install uv (https://docs.astral.sh/uv/)," >&2
  echo "or pipx, or run: pip3 install --user youtube-transcript-api" >&2
  exit 2
fi

# The CLI prints errors to stdout and exits 0 on failure, so inspect the text
OUTPUT=$("${RUN[@]}" "$VIDEO_ID" --languages "${LANGS[@]}" --format text 2>&1) || true

if printf '%s' "$OUTPUT" | grep -q "YouTube is blocking"; then
  echo "YouTube is blocking requests from this IP (common on cloud machines and VPSs)." >&2
  echo "Skipping YouTube for this run." >&2
  exit 2
fi

if [ -z "$OUTPUT" ] || printf '%s' "$OUTPUT" | grep -q "Could not retrieve a transcript"; then
  printf '%s\n' "$OUTPUT" >&2
  exit 1
fi

printf '%s\n' "$OUTPUT"

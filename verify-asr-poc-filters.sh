#!/usr/bin/env bash
set -euo pipefail

FFMPEG_BIN="${1:-./workspace/bin/ffmpeg}"
MODE="${2:-exec}"

if [[ ! -f "$FFMPEG_BIN" ]]; then
  echo "ERROR: ffmpeg binary not found: $FFMPEG_BIN" >&2
  exit 1
fi

echo "Verifying ASR POC FFmpeg capabilities: $FFMPEG_BIN"
required_filters=(
  afftdn
  anequalizer
  arnndn
  asetpts
  aresample
  atrim
  highpass
  loudnorm
  lowpass
  silencedetect
  silenceremove
  speechnorm
  volume
)

if [[ "$MODE" == "exec" ]]; then
  if [[ ! -x "$FFMPEG_BIN" ]]; then
    echo "ERROR: ffmpeg binary is not executable: $FFMPEG_BIN" >&2
    exit 1
  fi

  "$FFMPEG_BIN" -version

  buildconf="$("$FFMPEG_BIN" -buildconf 2>&1)"
  if grep -q -- '--enable-gpl' <<<"$buildconf"; then
    echo "ERROR: GPL flag detected in LGPL build" >&2
    exit 1
  fi

  filters="$("$FFMPEG_BIN" -hide_banner -filters 2>&1)"
  filter_pattern='^[[:space:]]*[TSC\.A-Z|]+[[:space:]]+%s[[:space:]]'
elif [[ "$MODE" == "strings" ]]; then
  if ! command -v strings >/dev/null 2>&1; then
    echo "ERROR: strings command is required for strings mode" >&2
    exit 1
  fi

  binary_strings="$(strings "$FFMPEG_BIN")"
  if grep -q -- '--enable-gpl' <<<"$binary_strings"; then
    echo "ERROR: GPL flag detected in LGPL build" >&2
    exit 1
  fi

  filters="$binary_strings"
  filter_pattern='^%s$'
else
  echo "ERROR: unknown verification mode: $MODE" >&2
  exit 1
fi

missing=()
for filter in "${required_filters[@]}"; do
  pattern="$(printf "$filter_pattern" "$filter")"
  if ! grep -Eq "$pattern" <<<"$filters"; then
    missing+=("$filter")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "ERROR: missing required ASR POC filters: ${missing[*]}" >&2
  exit 1
fi

echo "ASR POC filter verification passed."

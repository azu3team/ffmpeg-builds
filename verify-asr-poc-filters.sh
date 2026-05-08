#!/usr/bin/env bash
set -euo pipefail

FFMPEG_BIN="${1:-./workspace/bin/ffmpeg}"

if [[ ! -x "$FFMPEG_BIN" ]]; then
  echo "ERROR: ffmpeg binary not found or not executable: $FFMPEG_BIN" >&2
  exit 1
fi

echo "Verifying ASR POC FFmpeg capabilities: $FFMPEG_BIN"
"$FFMPEG_BIN" -version

buildconf="$("$FFMPEG_BIN" -buildconf 2>&1)"
if grep -q -- '--enable-gpl' <<<"$buildconf"; then
  echo "ERROR: GPL flag detected in LGPL build" >&2
  exit 1
fi

filters="$("$FFMPEG_BIN" -hide_banner -filters 2>&1)"
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

missing=()
for filter in "${required_filters[@]}"; do
  if ! grep -Eq "^[[:space:]]*[TSC\.A-Z|]+[[:space:]]+$filter[[:space:]]" <<<"$filters"; then
    missing+=("$filter")
  fi
done

if (( ${#missing[@]} > 0 )); then
  echo "ERROR: missing required ASR POC filters: ${missing[*]}" >&2
  exit 1
fi

echo "ASR POC filter verification passed."

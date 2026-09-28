#!/usr/bin/env bash

set -euo pipefail

readonly flutter_version="3.47.1"

if command -v flutter >/dev/null 2>&1; then
  flutter_bin="$(command -v flutter)"
else
  flutter_dir="${TMPDIR:-/tmp}/flutter-sdk-${flutter_version}"
  flutter_bin="${flutter_dir}/bin/flutter"

  if [[ ! -x "${flutter_bin}" ]]; then
    git clone --depth 1 --branch "${flutter_version}" \
      https://github.com/flutter/flutter.git "${flutter_dir}"
  fi
fi

"${flutter_bin}" config --no-analytics
"${flutter_bin}" pub get
"${flutter_bin}" build web --release

#!/bin/bash

set -euo pipefail

VERSION="${1:-0.1.0}"
ARCH_INPUT="${2:-$(uname -m)}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_WORKSPACE="${SOURCE_WORKSPACE:-/Users/shiz/code/ros2_kilted}"
PYTHON_BIN="${PYTHON_BIN:-$SOURCE_WORKSPACE/.venv/bin/python3}"
DIST_DIR="$ROOT/dist"
STAGE_ROOT="$DIST_DIR/stage"
FOONATHAN_REF="${FOONATHAN_REF:-vendor-1.4.1}"
GOOGLE_BENCHMARK_REF="${GOOGLE_BENCHMARK_REF:-v1.8.3}"
MIMICK_REF="${MIMICK_REF:-1e138b0e13da99278453dc96af954890d9f48348}"

case "$ARCH_INPUT" in
  arm64|aarch64)
    ARCH_SUFFIX="arm64"
    ;;
  x86_64|amd64)
    ARCH_SUFFIX="x86_64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH_INPUT" >&2
    exit 1
    ;;
esac

HOST_ARCH_RAW="$(uname -m)"
case "$HOST_ARCH_RAW" in
  arm64|aarch64)
    HOST_ARCH_SUFFIX="arm64"
    ;;
  x86_64|amd64)
    HOST_ARCH_SUFFIX="x86_64"
    ;;
  *)
    echo "Unsupported host architecture: $HOST_ARCH_RAW" >&2
    exit 1
    ;;
esac

if [[ "$HOST_ARCH_SUFFIX" != "$ARCH_SUFFIX" ]]; then
  cat >&2 <<EOF
Requested release architecture '$ARCH_SUFFIX' does not match host architecture '$HOST_ARCH_SUFFIX'.
Build each release tarball on a matching machine because the bundled Python wheelhouse is architecture-specific.
EOF
  exit 1
fi

BUNDLE_NAME="ros2-kilted-core-$VERSION-$ARCH_SUFFIX"
STAGE_DIR="$STAGE_ROOT/$BUNDLE_NAME"
TARBALL="$DIST_DIR/$BUNDLE_NAME.tar.gz"
SHA_FILE="$DIST_DIR/$BUNDLE_NAME.sha256"
VENDOR_SRC_DIR="$STAGE_DIR/packaging/homebrew/vendor-src"
FOONATHAN_STAGE_DIR="$VENDOR_SRC_DIR/foonathan_memory"
FOONATHAN_ARCHIVE="${DIST_DIR}/foonathan_memory-${FOONATHAN_REF}.tar.gz"
FOONATHAN_URL="${FOONATHAN_URL:-https://github.com/eProsima/memory/archive/refs/tags/${FOONATHAN_REF}.tar.gz}"
GOOGLE_BENCHMARK_STAGE_DIR="$VENDOR_SRC_DIR/google_benchmark"
GOOGLE_BENCHMARK_ARCHIVE="${DIST_DIR}/google_benchmark-${GOOGLE_BENCHMARK_REF}.tar.gz"
GOOGLE_BENCHMARK_URL="${GOOGLE_BENCHMARK_URL:-https://github.com/google/benchmark/archive/refs/tags/${GOOGLE_BENCHMARK_REF}.tar.gz}"
MIMICK_STAGE_DIR="$VENDOR_SRC_DIR/mimick"
MIMICK_ARCHIVE="${DIST_DIR}/mimick-${MIMICK_REF}.tar.gz"
MIMICK_URL="${MIMICK_URL:-https://github.com/ros2/Mimick/archive/${MIMICK_REF}.tar.gz}"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_ROOT" "$DIST_DIR"

rsync -a \
  --exclude ".git" \
  --exclude "/.ros" \
  --exclude "/.venv" \
  --exclude "/build" \
  --exclude "/install" \
  --exclude "/log" \
  "$SOURCE_WORKSPACE/" "$STAGE_DIR/"

mkdir -p "$STAGE_DIR/packaging/homebrew/wheelhouse" "$VENDOR_SRC_DIR"
"$PYTHON_BIN" -m pip download \
  --dest "$STAGE_DIR/packaging/homebrew/wheelhouse" \
  -r "$STAGE_DIR/packaging/homebrew/requirements-build.txt"

rm -rf "$FOONATHAN_STAGE_DIR"
mkdir -p "$FOONATHAN_STAGE_DIR"
curl -L "$FOONATHAN_URL" -o "$FOONATHAN_ARCHIVE"
tar -xzf "$FOONATHAN_ARCHIVE" -C "$FOONATHAN_STAGE_DIR" --strip-components=1

rm -rf "$GOOGLE_BENCHMARK_STAGE_DIR"
mkdir -p "$GOOGLE_BENCHMARK_STAGE_DIR"
curl -L "$GOOGLE_BENCHMARK_URL" -o "$GOOGLE_BENCHMARK_ARCHIVE"
tar -xzf "$GOOGLE_BENCHMARK_ARCHIVE" -C "$GOOGLE_BENCHMARK_STAGE_DIR" --strip-components=1

rm -rf "$MIMICK_STAGE_DIR"
mkdir -p "$MIMICK_STAGE_DIR"
curl -L "$MIMICK_URL" -o "$MIMICK_ARCHIVE"
tar -xzf "$MIMICK_ARCHIVE" -C "$MIMICK_STAGE_DIR" --strip-components=1

rm -f "$TARBALL" "$SHA_FILE"
tar -C "$STAGE_ROOT" -czf "$TARBALL" "$BUNDLE_NAME"
shasum -a 256 "$TARBALL" | awk '{print $1}' > "$SHA_FILE"

echo "Created $TARBALL"
echo "SHA256: $(cat "$SHA_FILE")"

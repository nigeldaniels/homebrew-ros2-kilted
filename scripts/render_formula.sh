#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT/Formula/ros2-kilted-core.rb.erb"
OUTPUT="$ROOT/Formula/ros2-kilted-core.rb"
GITHUB_ORG="${1:-YOUR_GITHUB_ORG}"
VERSION="${2:-0.1.0}"
ARM64_SHA256_VALUE="${3:-REPLACE_WITH_ARM64_SHA256}"
X86_64_SHA256_VALUE="${4:-REPLACE_WITH_X86_64_SHA256}"

export GITHUB_ORG VERSION ARM64_SHA256_VALUE X86_64_SHA256_VALUE TEMPLATE OUTPUT

/usr/bin/ruby <<'RUBY'
require "erb"

template_path = ENV.fetch("TEMPLATE")
output_path = ENV.fetch("OUTPUT")
github_org = ENV.fetch("GITHUB_ORG")
version = ENV.fetch("VERSION")
arm64_sha256 = ENV.fetch("ARM64_SHA256_VALUE")
x86_64_sha256 = ENV.fetch("X86_64_SHA256_VALUE")

renderer = ERB.new(File.read(template_path), trim_mode: "-")
File.write(output_path, renderer.result(binding))
RUBY

echo "Rendered $OUTPUT"

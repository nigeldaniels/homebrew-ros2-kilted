# homebrew-ros2-kilted

Homebrew tap for the curated macOS ROS 2 Kilted workspace built from `/Users/shiz/code/ros2_kilted`, intentionally excluding the separate tutorial overlay workspace.

## Structure

- `Formula/ros2-kilted-core.rb`
- `scripts/make_release_tarball.sh`
- `scripts/render_formula.sh`

This repository is intended to do two jobs:

1. act as the Homebrew tap
2. host the GitHub Release tarball asset the formula installs from

## Install flow for users

Once published under `YOUR_GITHUB_ORG/homebrew-ros2-kilted`, users can install directly with:

```bash
brew install YOUR_GITHUB_ORG/ros2-kilted/ros2-kilted-core
```

Because the repository name starts with `homebrew-`, Homebrew can also use the shorter tap name `YOUR_GITHUB_ORG/ros2-kilted`.

The formula automatically selects an `arm64` or `x86_64` release asset based on the installing Mac's CPU architecture, so users still run the same `brew install` command.

## Release flow

1. Build a new source bundle:

```bash
/Users/shiz/code/homebrew-ros2-kilted/scripts/make_release_tarball.sh 0.1.0 arm64
/Users/shiz/code/homebrew-ros2-kilted/scripts/make_release_tarball.sh 0.1.0 x86_64
```

Run each command on a machine with the matching CPU architecture. The release tarball includes an architecture-specific Python wheelhouse, so an `arm64` tarball must be built on an Apple Silicon Mac and an `x86_64` tarball must be built on an Intel Mac.

2. Render the formula with the real GitHub org and both tarball checksums:

```bash
/Users/shiz/code/homebrew-ros2-kilted/scripts/render_formula.sh YOUR_GITHUB_ORG 0.1.0 <arm64-sha256> <x86_64-sha256>
```

3. Create a GitHub release tag `v0.1.0` in this repository.
4. Upload both release assets:
   - `dist/ros2-kilted-core-0.1.0-arm64.tar.gz`
   - `dist/ros2-kilted-core-0.1.0-x86_64.tar.gz`
5. Commit and push the updated formula.

## Notes

- The release tarball is built from the curated `ros2_kilted` workspace and excludes `build`, `install`, `log`, `.venv`, and the tutorial overlay workspace.
- Python build/runtime tooling is vendored into each release tarball as a wheelhouse so the formula can install it reproducibly on that architecture.
- `foonathan_memory`, `google_benchmark`, and `Mimick`, which ROS vendor packages would otherwise fetch during the source build, are vendored into the release tarball so the Homebrew install can stay offline and reproducible.

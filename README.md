# homebrew-ros2-kilted

Homebrew tap for a curated macOS ROS 2 Kilted workspace

## What This Is

This tap packages a source-built, macOS-focused ROS 2 Kilted workspace into a Homebrew-installable formula.

It is meant to give developers a practical ROS 2 setup on macOS without asking them to manually:

- clone the ROS 2 source workspace
- run `vcs import`
- create a Python build environment
- figure out the right package subset to build
- work around the macOS-specific packaging issues we already solved

In other words, this repository is the installer/distribution layer for the curated ROS 2 workspace it packages.

## Install

```bash
brew install nigeldaniels/ros2-kilted/ros2-kilted-core
```

## What Users Are Installing

`ros2-kilted-core` installs a curated ROS 2 build that includes:

- the core ROS 2 runtime needed for normal development on macOS
- Fast DDS as the supported default RMW path
- ROS 2 CLI tools such as `ros2run`, `ros2node`, `ros2topic`, `ros2service`, `ros2action`, `ros2param`, `ros2interface`, `ros2doctor`, `ros2launch`, and `ros2bag`
- `turtlesim`
- `rqt_graph`, `rqt_console`, and `rqt_service_caller`

This is intentionally more than a tiny library formula, but less than a "ship every ROS package" distribution.

## What This Does Not Install

This formula does not try to be a perfect, full, stock ROS 2 desktop distribution.

Notably:

- it does not include the separate tutorial overlay workspace
- it does not aim to build every optional ROS 2 package
- it is curated around the package set we validated on macOS
- it is designed around the Fast DDS path we got working and tested

## What We Already Did For Users

The Homebrew package bakes in the setup and packaging work that would otherwise have to be done manually, including:

- curating a known-good package subset for macOS
- building the dependency closure from source
- bundling the Python build/runtime toolchain used by the workspace
- vendoring upstream sources that ROS vendor packages would otherwise download during install
- keeping the install path reproducible enough for Homebrew users

That means users do not need their own manual source checkout just to install the package. Homebrew downloads the release tarball and builds from that bundled source tree automatically.

## Installed Commands

The formula installs wrapper commands that source the packaged ROS environment before launching tools.

The main entrypoints are:

- `ros2-kilted`
- `ros2-kilted-env`
- `ros2-kilted-turtlesim`
- `ros2-kilted-rqt`
- `ros2-kilted-bag`

Examples:

```bash
ros2-kilted interface show geometry_msgs/msg/Twist
ros2-kilted-turtlesim
ros2-kilted-rqt
ros2-kilted-bag --help
```

We use these names instead of replacing plain `ros2` globally so this package can coexist more safely with other ROS installs.

## Structure

- `Formula/ros2-kilted-core.rb`
- `scripts/make_release_tarball.sh`
- `scripts/render_formula.sh`

This repository is intended to do two jobs:

1. act as the Homebrew tap
2. host the GitHub Release tarball asset the formula installs from

## Notes

- The release tarball is built from the curated `ros2_kilted` workspace and excludes `build`, `install`, `log`, `.venv`, and the tutorial overlay workspace.
- Python build/runtime tooling is vendored into each release tarball as a wheelhouse so the formula can install it reproducibly on that architecture.
- `foonathan_memory`, `google_benchmark`, and `Mimick`, which ROS vendor packages would otherwise fetch during the source build, are vendored into the release tarball so the Homebrew install can stay offline and reproducible.
- The formula was validated with a full isolated Homebrew-style build of the curated workspace on Apple Silicon macOS, plus smoke tests for `ros2 interface show ...` and `ros2 bag --help`.

class Ros2KiltedCore < Formula
  include Language::Python::Virtualenv

  desc "Curated ROS 2 Kilted runtime and tooling for macOS"
  homepage "https://github.com/nigeldaniels/homebrew-ros2-kilted"
  if Hardware::CPU.arm?
    url "https://github.com/nigeldaniels/homebrew-ros2-kilted/releases/download/v0.1.0/ros2-kilted-core-0.1.0-arm64.tar.gz"
    sha256 "d5214590e2b346b3507079b54a2cf83a8cad6f60b480b948cdbb68712e812ed9"
  else
    url "https://github.com/nigeldaniels/homebrew-ros2-kilted/releases/download/v0.1.0/ros2-kilted-core-0.1.0-x86_64.tar.gz"
    sha256 "REPLACE_WITH_X86_64_SHA256"
  end
  license "Apache-2.0"

  depends_on "asio"
  depends_on "cmake" => :build
  depends_on "cppcheck"
  depends_on "console_bridge"
  depends_on "libyaml"
  depends_on "pkgconf" => :build
  depends_on "graphviz"
  depends_on "openssl@3"
  depends_on "pybind11"
  depends_on "pyqt@5"
  depends_on "python@3.12"
  depends_on "qt@5"
  depends_on "spdlog"
  depends_on "sqlite"
  depends_on "tinyxml2"
  depends_on "uncrustify"
  depends_on "yaml-cpp"
  depends_on "zstd"

  def install
    python = Formula["python@3.12"].opt_bin/"python3.12"
    graphviz = Formula["graphviz"]
    tools_venv = libexec/"tools-venv"
    virtualenv_create(tools_venv, python)

    requirements = buildpath/"packaging/homebrew/requirements-build.txt"
    wheelhouse = buildpath/"packaging/homebrew/wheelhouse"

    # pygraphviz is distributed as an sdist here, so point pip's build
    # environment at Homebrew's Graphviz headers and libraries.
    ENV["CFLAGS"] = [ENV["CFLAGS"], "-I#{graphviz.opt_include}"].compact.join(" ")
    ENV["CPPFLAGS"] = [ENV["CPPFLAGS"], "-I#{graphviz.opt_include}"].compact.join(" ")
    ENV["LDFLAGS"] = [ENV["LDFLAGS"], "-L#{graphviz.opt_lib}"].compact.join(" ")
    ENV["PKG_CONFIG_PATH"] = [(graphviz.opt_lib/"pkgconfig").to_s, ENV["PKG_CONFIG_PATH"]].compact.join(":")

    system tools_venv/"bin/pip", "install",
           "--no-index",
           "--find-links", wheelhouse,
           "-r", requirements

    cmake_prefix_path = [
      Formula["asio"].opt_prefix,
      Formula["cppcheck"].opt_prefix,
      Formula["console_bridge"].opt_prefix,
      Formula["libyaml"].opt_prefix,
      Formula["qt@5"].opt_prefix,
      Formula["pybind11"].opt_prefix,
      Formula["pyqt@5"].opt_prefix,
      Formula["openssl@3"].opt_prefix,
      Formula["spdlog"].opt_prefix,
      Formula["sqlite"].opt_prefix,
      Formula["tinyxml2"].opt_prefix,
      Formula["uncrustify"].opt_prefix,
      Formula["yaml-cpp"].opt_prefix,
      Formula["zstd"].opt_prefix,
      Formula["graphviz"].opt_prefix,
      HOMEBREW_PREFIX,
    ].join(";")

    env = {
      "ROS2_KILTED_ROOT" => buildpath,
      "ROS2_KILTED_BUILD_BASE" => buildpath/"build-homebrew",
      "ROS2_KILTED_INSTALL_BASE" => libexec/"install",
      "ROS2_KILTED_TOOLS_BIN" => tools_venv/"bin",
      "ROS2_KILTED_TOOLS_PYTHON" => tools_venv/"bin/python",
      "ROS2_KILTED_PACKAGE_SET_FILE" => buildpath/"packaging/homebrew/package-set.txt",
      "ROS2_KILTED_PACKAGE_SKIP_FILE" => buildpath/"packaging/homebrew/package-skip.txt",
      "ROS2_KILTED_CMAKE_PREFIX_PATH" => cmake_prefix_path,
      "ROS2_KILTED_HOMEBREW_PREFIX" => HOMEBREW_PREFIX,
      "ROS2_KILTED_QT_BIN" => Formula["qt@5"].opt_bin,
      "ROS2_KILTED_FOONATHAN_SOURCE_DIR" => buildpath/"packaging/homebrew/vendor-src/foonathan_memory",
      "ROS2_KILTED_GOOGLE_BENCHMARK_SOURCE_DIR" => buildpath/"packaging/homebrew/vendor-src/google_benchmark",
      "ROS2_KILTED_MIMICK_SOURCE_DIR" => buildpath/"packaging/homebrew/vendor-src/mimick",
      "PYTHONNOUSERSITE" => "1",
    }

    system env, "bash", buildpath/"packaging/homebrew/build_workspace.sh"

    Dir[buildpath/"packaging/homebrew/bin/*"].each do |template|
      inreplace template, "__ROS2_KILTED_LIBEXEC__", opt_libexec.to_s
      inreplace template, "__ROS2_KILTED_PREFIX__", opt_prefix.to_s
      bin.install template
    end
  end

  def caveats
    <<~EOS
      This formula installs the curated ROS 2 Kilted macOS workspace without the tutorial overlay.

        ros2-kilted interface show geometry_msgs/msg/Twist
        ros2-kilted-turtlesim
        ros2-kilted-rqt
        ros2-kilted-bag info /path/to/bag
        ros2-kilted-env
    EOS
  end

  test do
    output = shell_output("#{bin}/ros2-kilted interface show geometry_msgs/msg/Twist")
    assert_match "Vector3", output
  end
end

# typed: strict
# frozen_string_literal: true

# Homebrew formula for the Plura Desktop standalone runtime.
class PluraDesktop < Formula
  desc "Multi-profile runtime for ChatGPT Desktop"
  homepage "https://github.com/LJY0317/plura-desktop"
  url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.18/plura_desktop-0.1.18.tar.gz"
  sha256 "a4d6c3aa3d9e81f7838067404317eff6841c2a17f9b1e7e7562188f088501ee0"
  license "MIT"

  depends_on macos: :sonoma

  resource "runtime" do
    on_arm do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.18/plura-desktop-macos-arm64.zip"
      sha256 "a72e66f7c707ac7e9c59990c1e788da4064427c19abd683bab22d3ac46590503"
    end

    on_intel do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.18/plura-desktop-macos-x86_64.zip"
      sha256 "b8a76d36b7f7cdad3da3293ce37d19459209c616f3b4f4de2d513722fc7d5937"
    end
  end

  def install
    resource("runtime").stage do
      libexec.install Dir["*"]
    end
    (libexec/"plura-desktop").chmod 0755
    pkgshare.install "LICENSE", "README.md"
    (bin/"plura-desktop").write_env_script(
      libexec/"plura-desktop",
      PLURA_DESKTOP_STABLE_RUNTIME: opt_libexec/"plura-desktop",
    )
  end

  def caveats
    <<~EOS
      Plura Desktop creates managed ChatGPT profile selectors and profile state outside Homebrew.
      Remove managed profiles with `plura-desktop uninstall --profile N --yes` before uninstalling
      this formula. Quit managed ChatGPT Profile N windows before upgrading Plura Desktop.
    EOS
  end

  test do
    assert_match "Plura Desktop #{version}", shell_output("#{bin}/plura-desktop --version")
    assert_match opt_libexec.to_s, (bin/"plura-desktop").read
  end
end

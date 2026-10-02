# typed: strict
# frozen_string_literal: true

# Homebrew formula for the Plura Desktop standalone runtime.
class PluraDesktop < Formula
  desc "Multi-profile runtime for ChatGPT Desktop"
  homepage "https://github.com/LJY0317/plura-desktop"
  url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.17/plura_desktop-0.1.17.tar.gz"
  sha256 "fec06799c53f86830635b0b98fae2d49592014ebf77a7657d3e324242f1e0f53"
  license "MIT"

  depends_on macos: :sonoma

  resource "runtime" do
    on_arm do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.17/plura-desktop-macos-arm64", using: :nounzip
      sha256 "bdaa1267cf56777f37fe104d0f20f15804244452d6723db91bb49870d1aec436"
    end

    on_intel do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.17/plura-desktop-macos-x86_64", using: :nounzip
      sha256 "31e5d6dfc22d3588c096c48ec06f33a9e59cad78c92e7cc9208866a0fdc0aa19"
    end
  end

  def install
    resource("runtime").stage do
      source = Dir["*"].find { |path| File.file?(path) }
      odie "Downloaded Plura Desktop runtime is missing" if source.nil?
      libexec.install source => "plura-desktop"
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

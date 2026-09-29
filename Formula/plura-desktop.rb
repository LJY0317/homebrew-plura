# typed: strict
# frozen_string_literal: true

# Homebrew formula for the Plura Desktop standalone runtime.
class PluraDesktop < Formula
  desc "Multi-profile runtime for ChatGPT Desktop"
  homepage "https://github.com/LJY0317/plura-desktop"
  url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.16/plura_desktop-0.1.16.tar.gz"
  sha256 "cf5edebf252f1be84b3ceec5113a5e1ec09502fd8e172d130b2fdfd1ec8b431a"
  license "MIT"

  depends_on macos: :sonoma

  resource "runtime" do
    on_arm do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.16/plura-desktop-macos-arm64", using: :nounzip
      sha256 "7a78efd56768d60579e3f10ae9bc8b78691441d1e78a1cc95777255e314a2d43"
    end

    on_intel do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.16/plura-desktop-macos-x86_64", using: :nounzip
      sha256 "3b0e428a4e1d322cdd421998a223413761e24defbef0dd9b29ff03b59cb72017"
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

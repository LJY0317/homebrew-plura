# typed: strict
# frozen_string_literal: true

# Homebrew formula for the Plura Desktop standalone runtime.
class PluraDesktop < Formula
  desc "Multi-profile runtime for ChatGPT Desktop"
  homepage "https://github.com/LJY0317/plura-desktop"
  url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.15/plura_desktop-0.1.15.tar.gz"
  sha256 "486db281682c93f9612c55273d9f17a50fdbafa420daa10e9377919efa422b78"
  license "MIT"

  depends_on macos: :sonoma

  resource "runtime" do
    on_arm do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.15/plura-desktop-macos-arm64", using: :nounzip
      sha256 "e4d8cef3b92c137994aeb261245a7e1e469020ce6139ac10e0f46beba0503d2f"
    end

    on_intel do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.15/plura-desktop-macos-x86_64", using: :nounzip
      sha256 "ef276622b2e3bcf4e77084aaa7d1ba4134873ec672c65c22de5b186f479129e7"
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

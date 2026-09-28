# typed: strict
# frozen_string_literal: true

# Homebrew formula for the Plura Desktop standalone runtime.
class PluraDesktop < Formula
  desc "Multi-profile runtime for ChatGPT Desktop"
  homepage "https://github.com/LJY0317/plura-desktop"
  url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.13/plura_desktop-0.1.13.tar.gz"
  sha256 "e56a0bbd3e081d836228b58dd5d738ca1071167911c66aef2e7927bf4a6af7ea"
  license "MIT"

  depends_on macos: :monterey

  resource "runtime" do
    on_arm do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.13/plura-desktop-macos-arm64", using: :nounzip
      sha256 "bebd7230b652d5e98446a2ea1bad10f56aacac8269cdf4788da3b3010f166baa"
    end

    on_intel do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.13/plura-desktop-macos-x86_64", using: :nounzip
      sha256 "61a09f27647fe6cb98aac7a3ca7e2abad909b71295fc7a7884bd7a8b0bd7bb8c"
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

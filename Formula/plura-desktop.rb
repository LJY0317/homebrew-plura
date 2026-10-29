# typed: strict
# frozen_string_literal: true

# Homebrew formula for the Plura Desktop standalone runtime.
class PluraDesktop < Formula
  desc "Multi-profile runtime for ChatGPT Desktop"
  homepage "https://github.com/LJY0317/plura-desktop"
  url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.19/plura_desktop-0.1.19.tar.gz"
  sha256 "af3ad64ee9ff636575c13deb177664e683775729ec26529bf9741358c425ff91"
  license "MIT"

  depends_on macos: :sonoma

  resource "runtime" do
    on_arm do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.19/plura-desktop-macos-arm64.zip"
      sha256 "0f1b3a7c217b9ecaa95c1306d3f734140d609d4f2a044e90508e9674acb36ab1"
    end

    on_intel do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.19/plura-desktop-macos-x86_64.zip"
      sha256 "f273215ed41ab3da9e5ebbc6e17beb79bf756f4766b7efe9df836f88f563df46"
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

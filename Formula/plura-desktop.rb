# typed: strict
# frozen_string_literal: true

# Homebrew formula for the Plura Desktop standalone runtime.
class PluraDesktop < Formula
  desc "Multi-profile runtime for ChatGPT Desktop"
  homepage "https://github.com/LJY0317/plura-desktop"
  url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.14/plura_desktop-0.1.14.tar.gz"
  sha256 "e49d38ab9f59ccfa778ce71dfb0a79f5e10c912964a39cb3011f0da2b9da725c"
  license "MIT"

  depends_on macos: :sonoma

  resource "runtime" do
    on_arm do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.14/plura-desktop-macos-arm64", using: :nounzip
      sha256 "602f7784c8836b1987158c4b616b50001efea8bfc74c9ab377d42530d13124f5"
    end

    on_intel do
      url "https://github.com/LJY0317/plura-desktop/releases/download/v0.1.14/plura-desktop-macos-x86_64", using: :nounzip
      sha256 "965db671408862ce192312d08cb82f5ef2c9dbeb0d10c6e49cc53dde21855b59"
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

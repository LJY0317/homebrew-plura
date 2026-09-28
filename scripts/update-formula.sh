#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 VERSION [--check]" >&2
  exit 2
}

[ "$#" -ge 1 ] && [ "$#" -le 2 ] || usage
version=${1#v}
mode=${2:-}
[ -z "$mode" ] || [ "$mode" = "--check" ] || usage
case "$version" in
  *[!0-9.]*|.*|*..*|*.) usage ;;
esac

command -v gh >/dev/null 2>&1 || { echo "Error: gh is required." >&2; exit 2; }
command -v shasum >/dev/null 2>&1 || { echo "Error: shasum is required." >&2; exit 2; }
command -v python3 >/dev/null 2>&1 || { echo "Error: python3 is required." >&2; exit 2; }

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
template="$root/templates/plura-desktop.rb.in"
formula="$root/Formula/plura-desktop.rb"
tag="v$version"
upstream="LJY0317/plura-desktop"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/plura-homebrew-update.XXXXXX")
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT HUP INT TERM

immutable=$(gh api "repos/$upstream/releases/tags/$tag" --jq '.immutable')
[ "$immutable" = "true" ] || { echo "Error: $tag is not an immutable GitHub Release." >&2; exit 1; }

gh release download "$tag" --repo "$upstream" \
  --pattern SHA256SUMS \
  --pattern RELEASE-METADATA.json \
  --pattern "plura_desktop-$version.tar.gz" \
  --pattern plura-desktop-macos-arm64 \
  --pattern plura-desktop-macos-x86_64 \
  --dir "$tmp"

sha_for() {
  awk -v name="$1" '$2 == name {print $1}' "$tmp/SHA256SUMS"
}

sdist="plura_desktop-$version.tar.gz"
arm="plura-desktop-macos-arm64"
intel="plura-desktop-macos-x86_64"
sdist_sha=$(sha_for "$sdist")
arm_sha=$(sha_for "$arm")
intel_sha=$(sha_for "$intel")
for value in "$sdist_sha" "$arm_sha" "$intel_sha"; do
  [ "${#value}" -eq 64 ] || { echo "Error: release checksum lookup failed." >&2; exit 1; }
done

for asset in "$sdist" "$arm" "$intel"; do
  expected=$(sha_for "$asset")
  actual=$(shasum -a 256 "$tmp/$asset" | awk '{print $1}')
  [ "$actual" = "$expected" ] || { echo "Error: SHA-256 mismatch for $asset" >&2; exit 1; }
  gh attestation verify "$tmp/$asset" --repo "$upstream" >/dev/null
done

python3 - "$tmp/RELEASE-METADATA.json" "$tag" <<'PY'
import json
import sys
from pathlib import Path
metadata = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
if metadata.get("repository") != "LJY0317/plura-desktop":
    raise SystemExit("release metadata repository mismatch")
if metadata.get("sourceTag") != sys.argv[2]:
    raise SystemExit("release metadata sourceTag mismatch")
PY

rendered="$tmp/plura-desktop.rb"
python3 - "$template" "$rendered" "$version" "$sdist_sha" "$arm_sha" "$intel_sha" <<'PY'
import sys
from pathlib import Path
source = Path(sys.argv[1]).read_text(encoding="utf-8")
values = {
    "@@VERSION@@": sys.argv[3],
    "@@SDIST_SHA256@@": sys.argv[4],
    "@@ARM64_SHA256@@": sys.argv[5],
    "@@X86_64_SHA256@@": sys.argv[6],
}
for token, value in values.items():
    if token not in source:
        raise SystemExit(f"template token missing: {token}")
    source = source.replace(token, value)
if "@@" in source:
    raise SystemExit("unresolved formula template token")
Path(sys.argv[2]).write_text(source, encoding="utf-8")
PY

if [ "$mode" = "--check" ]; then
  cmp "$rendered" "$formula" || {
    echo "Error: Formula/plura-desktop.rb does not match verified $tag release data." >&2
    exit 1
  }
  echo "Formula already matches verified $tag release data."
else
  cp "$rendered" "$formula"
  echo "Updated Formula/plura-desktop.rb from verified $tag release data."
fi

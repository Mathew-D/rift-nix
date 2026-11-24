#!/bin/sh

set -e

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
repo_root=$(dirname "$script_dir")
cd "$repo_root"

page_url="https://riftforeve.online/download.html"
release_url=$(curl -fsSL "$page_url" | grep -oE 'https://riftforeve\.online/download/debian/rift_[0-9]+\.[0-9]+\.[0-9]+_amd64\.deb' | head -n 1)

if [ -z "$release_url" ]; then
    echo "Could not find the latest Rift .deb URL on $page_url" >&2
    exit 1
fi

rift_version=$(printf '%s\n' "$release_url" | sed -n 's/.*rift_\([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)_amd64\.deb/\1/p')
deb_path="/tmp/rift_${rift_version}_amd64.deb"

curl -fsSL -o "$deb_path" "$release_url"

# nix hash file prints a plain base64 string; add the Nix prefix used in fetchurl.
nix_hash="sha256-$(nix hash file --type sha256 --base64 "$deb_path")"

python3 -c 'import pathlib, re, sys; p = pathlib.Path(sys.argv[1]); version = sys.argv[2]; hash_value = sys.argv[3]; text = p.read_text(); text, c1 = re.subn(r"(version\s*=\s*\")([^\"]+)(\")", rf"\g<1>{version}\3", text, count=1); text, c2 = re.subn(r"(hash\s*=\s*\")([^\"]+)(\")", rf"\g<1>{hash_value}\3", text, count=1); assert c1 == 1 and c2 == 1, "Could not update both version and hash in pkgs/rift/default.nix"; p.write_text(text)' "$repo_root/pkgs/rift/default.nix" "$rift_version" "$nix_hash"

if [ -f "$repo_root/README.md" ]; then
    python3 -c 'import pathlib, re, sys; p = pathlib.Path(sys.argv[1]); version = sys.argv[2]; text = p.read_text(); new_text, count = re.subn(r"(?m)^Version:\s*.*$", f"Version: {version}", text); (p.write_text(new_text if count else text.rstrip() + "\nVersion: " + version + "\n"))' "$repo_root/README.md" "$rift_version"
fi

echo "Updated Rift to $rift_version"
echo "Nix hash: $nix_hash"

nix build .#rift --print-build-logs

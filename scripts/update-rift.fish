#!/usr/bin/env fish

set -l script_dir (dirname (status --current-filename))
set -l repo_root (dirname "$script_dir")
cd "$repo_root"

set -l page_url "https://riftforeve.online/download.html"
set -l release_url (curl -fsSL "$page_url" | string match -r 'https://riftforeve.online/download/debian/rift_[0-9]+\.[0-9]+\.[0-9]+_amd64\.deb' | head -n 1)

if test -z "$release_url"
    echo "Could not find the latest Rift .deb URL on $page_url" >&2
    exit 1
end

set -l rift_version (string replace -r '^.*rift_([0-9]+\.[0-9]+\.[0-9]+)_amd64\.deb$' '$1' "$release_url")
set -l deb_path "/tmp/rift_$rift_version_amd64.deb"

curl -fsSL -o "$deb_path" "$release_url"

# nix hash file prints a plain base64 string; add the Nix prefix used in fetchurl.
set -l nix_hash (string join '' "sha256-" (nix hash file --type sha256 --base64 "$deb_path"))

python3 -c 'import pathlib, re, sys; p = pathlib.Path(sys.argv[1]); version = sys.argv[2]; hash_value = sys.argv[3]; text = p.read_text(); text, c1 = re.subn(r"(version\s*=\s*\")([^\"]+)(\")", rf"\g<1>{version}\3", text, count=1); text, c2 = re.subn(r"(hash\s*=\s*\")([^\"]+)(\")", rf"\g<1>{hash_value}\3", text, count=1); assert c1 == 1 and c2 == 1, "Could not update both version and hash in pkgs/rift/default.nix"; p.write_text(text)' "$repo_root/pkgs/rift/default.nix" "$rift_version" "$nix_hash"

if test -f "$repo_root/README.md"
    python3 -c 'import pathlib, re, sys; p = pathlib.Path(sys.argv[1]); version = sys.argv[2]; text = p.read_text(); new_text, count = re.subn(r"(?m)^Version:\s*.*$", f"Version: {version}", text); (p.write_text(new_text if count else text.rstrip() + "\nVersion: " + version + "\n"))' "$repo_root/README.md" "$rift_version"
end

echo "Updated Rift to $rift_version"
echo "Nix hash: $nix_hash"

nix build .#rift --print-build-logs

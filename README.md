# rift-nix

A Nix flake for installing the **RIFT** client on **NixOS** and other Linux distributions with Nix.

This package installs the official RIFT client in a way that integrates cleanly with Nix, allowing you to install and update it using standard Nix commands.

## Features

* 📦 Simple Nix flake installation
* ❄️ Works on NixOS and other systems with Nix
* 🔄 Easy updates through flake inputs
* 🎮 Packages the official RIFT Linux release
* 🛠 No manual extraction or installation required

## Installation

Run directly without installing:

```bash
nix run github:<YOUR_GITHUB_USERNAME>/rift-nix
```

Install into your profile:

```bash
nix profile install github:<YOUR_GITHUB_USERNAME>/rift-nix
```

Or add it as a flake input:

```nix
{
  inputs.rift.url = "github:<YOUR_GITHUB_USERNAME>/rift-nix";

  outputs = { self, nixpkgs, rift, ... }:
  {
    # Your configuration here
  };
}
```

## Updating

To update to the latest version of the flake:

```bash
nix flake update
```

## Building

Clone the repository and build locally:

```bash
git clone https://github.com/<YOUR_GITHUB_USERNAME>/rift-nix.git
cd rift-nix
nix build
```

Run the resulting package:

```bash
./result/bin/rift
```

## Why this repository?

RIFT is not currently packaged in `nixpkgs`. This repository provides a maintained Nix flake so users can install the client without creating their own package.

## Requirements

* Nix with flakes enabled
* Linux (x86_64)

## Contributing

Issues and pull requests are welcome. If you encounter a problem or have an improvement, please open an issue or submit a pull request.

## License

The Nix packaging in this repository is licensed under the MIT License.

The RIFT client itself is proprietary software and remains the property of its respective owners. This repository only packages the official client for use with Nix.

# Go Installer

This repository contains a simple script to download and install the latest stable Go (Golang) distribution for Linux systems.

## Files
- README.md — this file
- install-go.sh — installation script

## Purpose
`install-go.sh` detects the latest Go release, downloads the appropriate tarball for your OS and architecture, installs Go to `/usr/local/go`, and adds `/usr/local/go/bin` to your shell profile so `go` is available.

## Prerequisites
- A Linux system
- `sudo` privileges to install into `/usr/local`
- Either `curl` or `wget` installed

## Usage
1. Make the script executable:

```bash
chmod +x install-go.sh
```

2. Run the script from the repo directory:

```bash
./install-go.sh
```

The script will:
- Detect the latest Go version from https://go.dev
- Determine your OS and architecture
- Download the correct tarball (e.g. `go1.20.4.linux-amd64.tar.gz`)
- Install into `/usr/local/go` (using `sudo`)
- Add `/usr/local/go/bin` to one of your profile files (`~/.profile`, `~/.bashrc`, or `~/.zshrc`) depending on your shell

After the script finishes you should see a `go version` output. Open a new terminal or source your profile to load the updated PATH.

Example to reload immediately (for Bash):

```bash
source ~/.bashrc
go version
```

## What the script does (summary)
- Uses `curl` to fetch the latest version token from `https://go.dev/VERSION?m=text`.
- Maps `uname -m` to `amd64` or `arm64` (exits on unsupported arch).
- Downloads the tarball with `wget` or `curl`.
- Removes any existing `/usr/local/go` and extracts the new tarball there.
- Appends `export PATH=/usr/local/go/bin:$PATH` to your shell profile if not already present.

## Troubleshooting
- Permission errors during extraction: ensure you have `sudo` privileges.
  - You can run the script with a user that has sudo access; the script itself calls `sudo` where required.
- `go: command not found` after install:
  - Open a new terminal or run `source` on your profile file (see Usage).
  - Confirm `/usr/local/go/bin` was added to your profile file.
- Unsupported architecture message: the script currently supports `amd64` and `arm64` only.

## Security notes
- The script downloads from `https://go.dev/dl/`. Inspect the script before running if you have special security requirements.

## Customization
- The script is minimal and does not accept command-line arguments. To install a specific version, you can manually download the tarball from https://go.dev/dl and follow the same extraction steps:

```bash
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.20.4.linux-amd64.tar.gz
```

Then add `/usr/local/go/bin` to your PATH if needed.

## License
This repository has no explicit license. Add one if you plan to distribute.

## Contact / Next steps
If you'd like, I can:
- Add support for choosing a specific Go version
- Add architecture checks for more CPU types
- Provide an uninstall helper that removes `/usr/local/go` and the PATH line


# Go Installer

`install-go.sh` installs the latest stable Go (Golang) toolchain for your current OS/CPU by downloading the official tarball from `go.dev`, extracting it to `/usr/local/go`, and ensuring `/usr/local/go/bin` is on your `PATH`.

## What It Does

Running the script will:

- Detect the latest Go version from `https://go.dev/VERSION?m=text`
- Detect your OS (`uname -s`) and architecture (`uname -m`)
- Download the matching tarball from `https://go.dev/dl/`
- Replace any existing Go install at `/usr/local/go` (it runs `sudo rm -rf /usr/local/go`)
- Extract Go into `/usr/local/go`
- Append `export PATH=/usr/local/go/bin:$PATH` to one profile file (see below) if it is not already present
- Run `go version` to verify the install

## Supported Platforms

- OS: Linux and macOS (the script uses `uname -s` lowercased, e.g. `linux`, `darwin`)
- Arch: `amd64` (`x86_64`) and `arm64` (`aarch64`)

## Prerequisites

- `bash`
- `sudo` access (installs into `/usr/local`)
- `curl` (required; used to detect the latest version, and as a download fallback)
- Optional: `wget` (used for downloading if present)

## Install (Step-by-Step)

1. Make the script executable:

```bash
chmod +x install-go.sh
```

2. Run it from the repo directory:

```bash
./install-go.sh
```

3. Ensure your shell picks up the updated `PATH`.

The script writes the `PATH` line to exactly one of these files based on the `$SHELL` environment variable:

- If `$SHELL` ends in `zsh`: `~/.zshrc`
- If `$SHELL` ends in `bash`: `~/.bashrc`
- Otherwise: `~/.profile`

To activate immediately in your current session:

```bash
# bash
source ~/.bashrc

# zsh
source ~/.zshrc

go version
```

If you are unsure which file was changed, search for the line:

```bash
grep -nH "/usr/local/go/bin" ~/.bashrc ~/.zshrc ~/.profile 2>/dev/null || true
```

## Verify

After installation:

```bash
command -v go
go version
go env GOROOT
```

Expected `GOROOT` is `/usr/local/go`.

## Update Go

Re-run the script:

```bash
./install-go.sh
```

It will download the latest stable version and replace `/usr/local/go`.

## Uninstall

1. Remove the Go install directory:

```bash
sudo rm -rf /usr/local/go
```

2. Remove the `PATH` line from your profile file (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```bash
export PATH=/usr/local/go/bin:$PATH
```

Then start a new terminal (or `source` the profile file).

## Troubleshooting

- `curl: command not found`:
  - Install `curl` using your system package manager and re-run the script.
- `Unsupported architecture: ...`:
  - The script only supports `amd64` and `arm64`.
- Download fails / 404:
  - Confirm you can access `https://go.dev/dl/` from your network.
  - Corporate proxies may block or rewrite TLS connections.
- `go: command not found` after the script finishes:
  - Open a new terminal.
  - Confirm your profile contains `export PATH=/usr/local/go/bin:$PATH`.
  - Confirm the profile file you are using is actually loaded by your shell.
- Existing Go installs:
  - The script replaces `/usr/local/go` only. If you installed Go via Homebrew/apt/etc, you may still have another `go` earlier on your `PATH`.
  - Check resolution with: `command -v go` and `which -a go` (if available).

## Security Notes

- This script downloads and installs binaries from `go.dev` but does not verify checksums/signatures.
- Read `install-go.sh` before running if you have stricter supply-chain requirements.

## Files

- `README.md`: this file
- `install-go.sh`: installation script

## License

No license is currently included. Add one if you plan to distribute or accept contributions.

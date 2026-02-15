# Go Installer

This repo provides:

- `install-go.sh` (Linux/macOS): installs Go to `/usr/local/go` and ensures `/usr/local/go/bin` is on your `PATH`
- `install-go.ps1` (Windows): installs Go to `%LocalAppData%\Programs\Go` and adds `...\Go\bin` to your **User** `PATH`

## What It Does

Linux/macOS (`install-go.sh`) will:

- Detect the latest Go version from `https://go.dev/VERSION?m=text`
- Detect your OS (`uname -s`) and architecture (`uname -m`)
- Download the matching tarball from `https://go.dev/dl/`
- Replace any existing Go install at `/usr/local/go` (it runs `sudo rm -rf /usr/local/go`)
- Extract Go into `/usr/local/go`
- Append `export PATH=/usr/local/go/bin:$PATH` to one profile file (see below) if it is not already present
- Run `go version` to verify the install

Windows (`install-go.ps1`) will:

- Detect the latest Go version from `https://go.dev/VERSION?m=text`
- Detect your CPU architecture (`AMD64`/`ARM64`)
- Download the matching zip from `https://go.dev/dl/`
- Install Go into `%LocalAppData%\Programs\Go` (by default)
- Add `...\Go\bin` to your **User** `PATH` (no duplicates)
- Run `go version` to verify the install

## Supported Platforms

- Linux/macOS: `install-go.sh` (`amd64`/`arm64`)
- Windows: `install-go.ps1` (`AMD64`/`ARM64`)

## Prerequisites

- Linux/macOS (`install-go.sh`): `bash`, `sudo`, `curl` (optional: `wget`)
- Windows (`install-go.ps1`): PowerShell 5.1+ and internet access to `go.dev`

## Run From GitHub (Raw URL)

Linux/macOS (recommended, `curl`):

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rajibdpi/go-installer/main/install-go.sh)"
```

Linux/macOS (`wget`):

```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/rajibdpi/go-installer/main/install-go.sh)"
```

Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/rajibdpi/go-installer/main/install-go.ps1 | iex"
```

## Install (Step-by-Step)

Linux/macOS:

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

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-go.ps1
```

If the install directory already exists and you want to replace it:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-go.ps1 -Force
```

## Verify

After installation:

```bash
command -v go
go version
go env GOROOT
```

Expected `GOROOT` is `/usr/local/go`.

On Windows, expected `GOROOT` is the install directory (default: `%LocalAppData%\Programs\Go`).

## Update Go

Linux/macOS: re-run the script:

```bash
./install-go.sh
```

It will download the latest stable version and replace `/usr/local/go`.

Windows: re-run with `-Force` to replace the existing install directory:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-go.ps1 -Force
```

## Uninstall

Linux/macOS:

1. Remove the Go install directory:

```bash
sudo rm -rf /usr/local/go
```

2. Remove the `PATH` line from your profile file (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```bash
export PATH=/usr/local/go/bin:$PATH
```

Then start a new terminal (or `source` the profile file).

Windows:

1. Remove the install directory (default):

```powershell
Remove-Item -Recurse -Force "$env:LOCALAPPDATA\\Programs\\Go"
```

2. Remove the Go `bin` entry from your **User** PATH (via Windows settings), then open a new terminal.

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
- PowerShell execution policy errors on Windows:
  - Use the commands shown above with `-ExecutionPolicy Bypass`.
- Existing Go installs:
  - The script replaces `/usr/local/go` only. If you installed Go via Homebrew/apt/etc, you may still have another `go` earlier on your `PATH`.
  - Check resolution with: `command -v go` and `which -a go` (if available).

## Security Notes

- This script downloads and installs binaries from `go.dev` but does not verify checksums/signatures.
- Read `install-go.sh` / `install-go.ps1` before running if you have stricter supply-chain requirements.

## Files

- `README.md`: this file
- `install-go.sh`: installation script
- `install-go.ps1`: Windows installation script

## License

No license is currently included. Add one if you plan to distribute or accept contributions.

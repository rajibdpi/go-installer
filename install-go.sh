bash -c '
set -euo pipefail

log() { printf "\n==> %s\n" "$1"; }

# 1) Detect latest Go version (first token only)
log "Detecting latest Go version..."
GO_VERSION="$(curl -fsSL https://go.dev/VERSION?m=text | head -n1 | awk "{print \$1}")"
echo "Go version: $GO_VERSION"

# 2) Detect OS + Arch
log "Detecting OS/Arch..."
OS="$(uname -s | tr "[:upper:]" "[:lower:]")"
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64|amd64) ARCH="amd64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *) echo "Unsupported architecture: $ARCH_RAW" >&2; exit 1 ;;
esac
echo "OS: $OS"
echo "Arch: $ARCH"

# 3) Build download URL
TARBALL="${GO_VERSION}.${OS}-${ARCH}.tar.gz"
URL="https://go.dev/dl/${TARBALL}"
log "Will download: $URL"

# 4) Download (wget if available, else curl)
log "Downloading..."
if command -v wget >/dev/null 2>&1; then
  wget -q "$URL" -O "$TARBALL"
else
  curl -fsSLo "$TARBALL" "$URL"
fi
echo "Downloaded: $TARBALL"

# 5) Install
log "Installing to /usr/local/go (requires sudo)..."
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$TARBALL"
rm -f "$TARBALL"

# 6) Persist PATH (no duplicates)
log "Configuring PATH..."
SHELL_NAME="$(basename "${SHELL:-}")"
PROFILE="$HOME/.profile"
[ "$SHELL_NAME" = "zsh" ] && PROFILE="$HOME/.zshrc"
[ "$SHELL_NAME" = "bash" ] && PROFILE="$HOME/.bashrc"

LINE="export PATH=/usr/local/go/bin:\$PATH"
if [ -f "$PROFILE" ] && grep -Fq "/usr/local/go/bin" "$PROFILE"; then
  echo "PATH already configured in $PROFILE"
else
  echo "$LINE" >> "$PROFILE"
  echo "Added PATH line to $PROFILE"
fi

# 7) Activate for current shell + verify
export PATH=/usr/local/go/bin:$PATH
log "Verifying..."
go version

log "Done ✅ (open a new terminal to ensure PATH is loaded everywhere)"
'
# Go Installer for Windows (PowerShell)
# - Installs latest stable Go to a user-writable directory by default (no admin).
# - Updates USER PATH to include <InstallDir>\bin (no duplicates).
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File .\install-go.ps1
#   powershell -ExecutionPolicy Bypass -File .\install-go.ps1 -InstallDir "$env:LOCALAPPDATA\\Programs\\Go" -Force

[CmdletBinding()]
param(
  [string]$InstallDir = (Join-Path $env:LOCALAPPDATA "Programs\Go"),
  [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Log([string]$Message) {
  Write-Host ""
  Write-Host "==> $Message"
}

function Get-GoArch {
  $arch = $env:PROCESSOR_ARCHITECTURE
  switch ($arch) {
    "AMD64" { return "amd64" }
    "ARM64" { return "arm64" }
    default {
      throw "Unsupported architecture: $arch (supported: AMD64, ARM64)"
    }
  }
}

function Ensure-Tls12 {
  # PowerShell 5.1 may default to older TLS. This is a no-op on newer.
  try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  } catch {
    # Ignore; modern PowerShell uses SocketsHttpHandler.
  }
}

function Get-LatestGoVersion {
  Ensure-Tls12
  Log "Detecting latest Go version..."
  $v = (Invoke-RestMethod -Uri "https://go.dev/VERSION?m=text" -UseBasicParsing) -split "`n" | Select-Object -First 1
  $v = $v.Trim()
  if (-not $v.StartsWith("go")) {
    throw "Unexpected version response: '$v'"
  }
  Write-Host "Go version: $v"
  return $v
}

function Add-ToUserPath([string]$DirToAdd) {
  $current = [Environment]::GetEnvironmentVariable("Path", "User")
  if ($null -eq $current) { $current = "" }

  $parts = $current -split ";" | Where-Object { $_ -and $_.Trim() -ne "" }
  $normalized = $parts | ForEach-Object { $_.Trim().TrimEnd("\") }
  $target = $DirToAdd.Trim().TrimEnd("\")

  if ($normalized -contains $target) {
    Write-Host "PATH already contains: $DirToAdd"
    return
  }

  $new = if ($current.Trim() -eq "") { $DirToAdd } else { "$current;$DirToAdd" }
  [Environment]::SetEnvironmentVariable("Path", $new, "User")
  $env:Path = "$env:Path;$DirToAdd"
  Write-Host "Added to USER PATH: $DirToAdd"
}

function Remove-IfExists([string]$Path) {
  if (Test-Path -LiteralPath $Path) {
    if (-not $Force) {
      throw "Install directory already exists: $Path (re-run with -Force to replace)"
    }
    Log "Removing existing install: $Path"
    Remove-Item -LiteralPath $Path -Recurse -Force
  }
}

Log "Detecting OS/Arch..."
$arch = Get-GoArch
Write-Host "OS: windows"
Write-Host "Arch: $arch"

$goVersion = Get-LatestGoVersion
$zipName = "$goVersion.windows-$arch.zip"
$url = "https://go.dev/dl/$zipName"
Log "Will download: $url"

$tmp = Join-Path $env:TEMP $zipName
Log "Downloading..."
Ensure-Tls12
Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
Write-Host "Downloaded: $tmp"

Log "Installing to: $InstallDir"
Remove-IfExists $InstallDir
New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null

# The zip contains a top-level "go\" folder. Extract to a temp dir, then move its contents into $InstallDir.
$extractRoot = Join-Path $env:TEMP ("go-extract-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null

try {
  Expand-Archive -LiteralPath $tmp -DestinationPath $extractRoot -Force
  $src = Join-Path $extractRoot "go"
  if (-not (Test-Path -LiteralPath $src)) {
    throw "Unexpected archive layout: missing '$src'"
  }
  Get-ChildItem -LiteralPath $src -Force | ForEach-Object {
    Move-Item -LiteralPath $_.FullName -Destination $InstallDir
  }
} finally {
  Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
}

$goBin = Join-Path $InstallDir "bin"
Log "Configuring PATH (User)..."
Add-ToUserPath $goBin

Log "Verifying..."
& (Join-Path $goBin "go.exe") version

Log "Done (open a new terminal to ensure PATH is loaded everywhere)"

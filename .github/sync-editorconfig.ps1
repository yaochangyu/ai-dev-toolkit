#!/usr/bin/env pwsh
# Sync .editorconfig to Windows home folder and WSL

$source = Join-Path $PSScriptRoot ".editorconfig"

if (-Not (Test-Path $source)) {
    Write-Error "Source file not found: $source"
    exit 1
}

# --- Windows: home folder ---
$windowsDest = Join-Path $HOME ".editorconfig\.net\.editorconfig"
New-Item -ItemType Directory -Path (Split-Path $windowsDest) -Force | Out-Null
Copy-Item -Path $source -Destination $windowsDest -Force
Write-Host "OK Windows: $windowsDest"

# --- WSL: ~/.editorconfig/.net/.editorconfig ---
$wslSrc = wsl wslpath -u ($source -replace '\\', '/')
wsl bash -c "mkdir -p ~/.editorconfig/.net && cp '$wslSrc' ~/.editorconfig/.net/.editorconfig"
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK WSL:     ~/.editorconfig/.net/.editorconfig"
} else {
    Write-Error "WSL copy failed. Please ensure WSL is installed and running."
    exit 1
}

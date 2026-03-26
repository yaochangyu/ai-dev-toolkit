#Requires -Version 5.1
<#
.SYNOPSIS
    Link copilot-instructions.md to AI agent folders
.DESCRIPTION
    Create hard links or symbolic links of copilot-instructions.md to user home AI agent folders
    Supports both Windows and WSL environments
.PARAMETER WslUser
    WSL username. Defaults to current Windows username.
.EXAMPLE
    .\link-ai-instructions.ps1
.EXAMPLE
    .\link-ai-instructions.ps1 -WslUser myuser
#>

param(
    [string]$WslUser = $env:USERNAME
)

$ErrorActionPreference = 'Stop'

$root = $env:USERPROFILE
$source = Join-Path $PSScriptRoot 'copilot-instructions.md'

$targets = @(
    (Join-Path $root '.github\copilot-instructions.md')
    (Join-Path $root '.copilot\copilot-instructions.md')
    (Join-Path $root '.claude\CLAUDE.md')
    (Join-Path $root '.gemini\GEMINI.md')
)

foreach ($target in $targets) {
    $dir = Split-Path $target -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

foreach ($target in $targets) {
    if (Test-Path $target) {
        Remove-Item -Path $target -Force
    }
    $targetDrive = (Split-Path -Qualifier $target)
    $sourceDrive = (Split-Path -Qualifier $source)
    if ($targetDrive -and $sourceDrive -and $targetDrive.ToLower() -eq $sourceDrive.ToLower()) {
        New-Item -ItemType HardLink -Path $target -Target $source | Out-Null
    } else {
        try {
            New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
        } catch {
            Copy-Item -Path $source -Destination $target -Force
            Write-Host "SymbolicLink unavailable; copied file instead: $target"
        }
    }
}

Write-Host "Windows links created from: $source"

$wslHome = "/home/$WslUser"
$wslSourceFromWindows = wsl wslpath -u ($source -replace '\\', '/')
$wslHomeEsc = $wslHome -replace "'","'\\''"
$wslSourceFromWindowsEsc = $wslSourceFromWindows -replace "'","'\\''"

$wslTargets = @(
    "$wslHome/.github/copilot-instructions.md",
    "$wslHome/.copilot/copilot-instructions.md",
    "$wslHome/.claude/CLAUDE.md",
    "$wslHome/.gemini/GEMINI.md"
)

$wslDirCommands = $wslTargets | ForEach-Object {
    $dir = (Split-Path $_ -Parent) -replace '\\','/'
    $dirEsc = $dir -replace "'","'\\''"
    "mkdir -p '$dirEsc'"
}
$wslLinkCommands = $wslTargets | ForEach-Object {
    $targetEsc = $_ -replace "'","'\\''"
    "rm -f '$targetEsc'; ln -sf '$wslSourceFromWindowsEsc' '$targetEsc'; echo 'WSL link created: $targetEsc'"
}

$wslCommandParts = @(
    'set -e'
) + $wslDirCommands + $wslLinkCommands

$wslCommand = $wslCommandParts -join '; '

wsl.exe -d Ubuntu-24.04 -- /bin/bash -lc $wslCommand

Write-Host "WSL links created from: $wslSourceFromWindows"

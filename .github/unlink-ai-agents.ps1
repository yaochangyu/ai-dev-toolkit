#Requires -Version 5.1
<#
.SYNOPSIS
    Unlink/Remove AI agent configurations from user home directory
.DESCRIPTION
    Removes items in .copilot, .gemini, .claude, .github folders under user home
    that were synced from this repository. Supports both Windows and WSL.
.PARAMETER WslUser
    WSL username. Defaults to current Windows username.
.EXAMPLE
    .\unlink-ai-agents.ps1
#>

param(
    [string]$WslUser = $env:USERNAME
)

$ErrorActionPreference = 'Stop'

$userHome = $env:USERPROFILE

# Define target folders under user home directory
$targetDirs = @(
    '.copilot',
    '.gemini',
    '.claude',
    '.github'
)

# Define items that were synced
$itemsToUnlink = @(
    'agents',
    'prompts',
    'skills',
    'mcp-config.json',
    'README.md',
    'copilot-instructions.md',
    'GEMINI.md',
    'CLAUDE.md'
)

Write-Host "Unlinking/Removing AI agent configurations from user home..." -ForegroundColor Yellow
Write-Host "Target base: $userHome" -ForegroundColor Gray
Write-Host ""

foreach ($targetDirName in $targetDirs) {
    $targetBase = Join-Path $userHome $targetDirName
    
    if (-not (Test-Path $targetBase)) {
        continue
    }
    
    Write-Host "Processing ~\$targetDirName..." -ForegroundColor Cyan
    
    foreach ($item in $itemsToUnlink) {
        $targetPath = Join-Path $targetBase $item
        
        if (Test-Path $targetPath) {
            try {
                Remove-Item -Path $targetPath -Recurse -Force -ErrorAction Stop
                Write-Host "  [OK] Removed: $item" -ForegroundColor Green
            }
            catch {
                Write-Host "  [ERROR] Failed to remove $item: $_" -ForegroundColor Red
            }
        }
    }
    
    # Optional: Remove empty target directories
    $remainingItems = Get-ChildItem -Path $targetBase -ErrorAction SilentlyContinue
    if ($null -eq $remainingItems -or $remainingItems.Count -eq 0) {
        # Check if it's really empty (including hidden files)
        $allContent = Get-ChildItem -Path $targetBase -Force -ErrorAction SilentlyContinue
        if ($null -eq $allContent -or $allContent.Count -eq 0) {
            # We don't remove the folder itself by default to avoid deleting user custom files
            # but we show a message.
            Write-Host "  [INFO] Folder ~\$targetDirName is now empty." -ForegroundColor Gray
        }
    }
    
    Write-Host ""
}

# WSL cleanup (if on Windows)
if ($IsWindows -or (-not (Get-Variable IsWindows -ErrorAction SilentlyContinue))) {
    Write-Host "Processing WSL environment..." -ForegroundColor Yellow
    
    # Check if WSL is available
    try {
        $wslCheck = wsl.exe -l -q 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[WARN] WSL unavailable, skipping WSL cleanup" -ForegroundColor Yellow
            exit 0
        }
    }
    catch {
        Write-Host "[WARN] WSL unavailable, skipping WSL cleanup" -ForegroundColor Yellow
        exit 0
    }
    
    $wslHome = "/home/$WslUser"
    $commands = @('set -e')
    
    foreach ($targetDirName in $targetDirs) {
        $wslTargetBase = "$wslHome/$targetDirName"
        $wslTargetBaseEsc = $wslTargetBase -replace "'","'\\''"
        
        foreach ($item in $itemsToUnlink) {
            $wslTargetPath = "$wslTargetBase/$item"
            $wslTargetPathEsc = $wslTargetPath -replace "'","'\\''"
            
            $commands += "if [ -e '$wslTargetPathEsc' ] || [ -L '$wslTargetPathEsc' ]; then rm -rf '$wslTargetPathEsc' && echo '  [OK] WSL Removed: ~/$targetDirName/$item'; fi"
        }
    }
    
    $wslCommand = $commands -join '; '
    
    try {
        wsl.exe -d Ubuntu-24.04 -- /bin/bash -lc $wslCommand
        Write-Host ""
        Write-Host "[OK] WSL cleanup completed" -ForegroundColor Green
    }
    catch {
        Write-Host "[WARN] WSL cleanup failed: $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Cleanup completed!" -ForegroundColor Green

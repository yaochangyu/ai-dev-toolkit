#Requires -Version 5.1
<#
.SYNOPSIS
    Link/Sync .github folder to AI agent folders in user home directory
.DESCRIPTION
    Links or Copies .github folder content to .copilot, .gemini, .claude, .github folders under user home
    Supports both Windows and WSL environments.
    By default, it uses Copy mode for better stability.
.PARAMETER UseSymlink
    Use Symbolic Link instead of Copy. Note: May require Administrator privileges on Windows.
.PARAMETER WslUser
    WSL username. Defaults to current Windows username.
.EXAMPLE
    .\link-ai-agents.ps1
.EXAMPLE
    .\link-ai-agents.ps1 -UseSymlink
#>

param(
    [switch]$UseSymlink,
    [string]$WslUser = $env:USERNAME
)

$ErrorActionPreference = 'Stop'

$sourceDir = $PSScriptRoot  # .github folder
$userHome = $env:USERPROFILE

# Define target folders under user home directory
$targetDirs = @(
    '.copilot',
    '.gemini',
    '.claude',
    '.github'
)

# Define files and folders to sync (relative to .github)
$itemsToSync = @(
    'agents',
    'prompts',
    'skills',
    'mcp-config.json',
    'README.md',
    'GEMINI.md',
    'CLAUDE.md'
)

$modeStr = if ($UseSymlink) { "Symbolic Link" } else { "Copy" }
Write-Host "Linking .github folder to user home AI agent folders..." -ForegroundColor Cyan
Write-Host "Mode: $modeStr" -ForegroundColor Yellow
Write-Host "Source folder: $sourceDir" -ForegroundColor Gray
Write-Host "Target base: $userHome" -ForegroundColor Gray
Write-Host ""

foreach ($targetDirName in $targetDirs) {
    $targetBase = Join-Path $userHome $targetDirName
    
    # Ensure target base folder exists
    if (-not (Test-Path $targetBase)) {
        New-Item -ItemType Directory -Path $targetBase -Force | Out-Null
        Write-Host "[OK] Created folder: ~\$targetDirName" -ForegroundColor Green
    }
    
    foreach ($item in $itemsToSync) {
        $sourcePath = Join-Path $sourceDir $item
        $targetPath = Join-Path $targetBase $item
        
        if (-not (Test-Path $sourcePath)) {
            # Skip optional files if they don't exist
            continue
        }
        
        # Delete existing target (might be old link or file)
        if (Test-Path $targetPath) {
            Remove-Item -Path $targetPath -Recurse -Force
        }
        
        $sourceItem = Get-Item $sourcePath
        $itemType = if ($sourceItem.PSIsContainer) { "Folder" } else { "File" }
        
        if ($UseSymlink) {
            try {
                New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -ErrorAction Stop | Out-Null
                Write-Host "  [OK] Link: ~\$targetDirName\$item ($itemType)" -ForegroundColor Green
            }
            catch {
                Write-Host "  [WARN] Symlink failed, falling back to Copy: $_" -ForegroundColor Yellow
                Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
                Write-Host "  [OK] Copy: ~\$targetDirName\$item ($itemType)" -ForegroundColor Green
            }
        }
        else {
            Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
            Write-Host "  [OK] Copy: ~\$targetDirName\$item ($itemType)" -ForegroundColor Green
        }
    }
    
    Write-Host ""
}

# WSL sync (if on Windows)
if ($IsWindows -or (-not (Get-Variable IsWindows -ErrorAction SilentlyContinue))) {
    Write-Host "Processing WSL environment..." -ForegroundColor Cyan
    
    # Check if WSL is available
    try {
        $wslCheck = wsl.exe -l -q 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[WARN] WSL unavailable, skipping WSL sync" -ForegroundColor Yellow
            exit 0
        }
    }
    catch {
        Write-Host "[WARN] WSL unavailable, skipping WSL sync" -ForegroundColor Yellow
        exit 0
    }
    
    $wslHome = "/home/$WslUser"
    $drive = $sourceDir.Substring(0, 1).ToLower()
    $pathNoDrive = $sourceDir.Substring(2) -replace '\\','/'
    $wslSourceDir = "/mnt/$drive$pathNoDrive"
    
    $wslSourceDirEsc = $wslSourceDir -replace "'","'\\''"
    
    $commands = @('set -e')
    
    foreach ($targetDirName in $targetDirs) {
        $wslTargetBase = "$wslHome/$targetDirName"
        $wslTargetBaseEsc = $wslTargetBase -replace "'","'\\''"
        
        # Create target folder
        $commands += "mkdir -p '$wslTargetBaseEsc'"
        
        foreach ($item in $itemsToSync) {
            $wslSourcePath = "$wslSourceDir/$item"
            $wslTargetPath = "$wslTargetBase/$item"
            
            $wslSourcePathEsc = $wslSourcePath -replace "'","'\\''"
            $wslTargetPathEsc = $wslTargetPath -replace "'","'\\''"
            
            # Delete old link/file
            $commands += "rm -rf '$wslTargetPathEsc'"
            
            if ($UseSymlink) {
                $commands += "ln -sf '$wslSourcePathEsc' '$wslTargetPathEsc'"
                $commands += "echo '  [OK] WSL Link: ~/$targetDirName/$item'"
            }
            else {
                $commands += "cp -r '$wslSourcePathEsc' '$wslTargetPathEsc'"
                $commands += "echo '  [OK] WSL Copy: ~/$targetDirName/$item'"
            }
        }
    }
    
    $wslCommand = $commands -join '; '
    
    try {
        # Using Ubuntu-24.04 as default as per previous script
        wsl.exe -d Ubuntu-24.04 -- /bin/bash -lc $wslCommand
        Write-Host ""
        Write-Host "[OK] WSL sync completed" -ForegroundColor Green
    }
    catch {
        Write-Host "[WARN] WSL sync failed: $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Sync completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Tips:" -ForegroundColor Cyan
if ($UseSymlink) {
    Write-Host "- Symbolic links will auto-sync .github changes" -ForegroundColor Gray
} else {
    Write-Host "- Re-run this script to update items in your home directory" -ForegroundColor Gray
}

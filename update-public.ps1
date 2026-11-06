#Requires -Version 5.1
<#
    Copy the latest public.json from TG Proxy Hub into this site folder
    and (optionally) commit + push it to GitHub.

    Examples:
        .\update-public.ps1
        .\update-public.ps1 -Push
#>
[CmdletBinding()]
param(
    [string]$Source = "C:\Projects\TG-Proxy-Hub\data\public.json",
    [switch]$Push,
    [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$siteRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$destination = Join-Path $siteRoot "public.json"

if (-not (Test-Path -LiteralPath $Source)) {
    throw "Source public.json not found: $Source"
}

if (-not (Test-Path -LiteralPath $destination)) {
    throw "Site public.json not found: $destination"
}

$before = (Get-Item -LiteralPath $destination).LastWriteTimeUtc
Copy-Item -LiteralPath $Source -Destination $destination -Force
$after = (Get-Item -LiteralPath $destination).Length
Write-Host "[OK] public.json updated from $Source ($after bytes)"

if (-not $Push) {
    Write-Host "[INFO] local copy only. Re-run with -Push to commit and push."
    return
}

Push-Location $siteRoot
try {
    if (-not (Test-Path -LiteralPath (Join-Path $siteRoot ".git"))) {
        throw "This folder is not a git repository. Run: git init; git add .; git commit -m 'init'"
    }

    $changes = git status --porcelain -- public.json
    if (-not $changes) {
        Write-Host "[INFO] public.json is unchanged, nothing to commit."
        return
    }

    $stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    git add public.json
    git commit -m "data: update public.json ($stamp)" | Out-Null
    git push origin $Branch
    Write-Host "[OK] committed and pushed to origin/$Branch"
}
finally {
    Pop-Location
}

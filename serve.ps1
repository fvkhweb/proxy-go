#Requires -Version 5.1
<#
    Serve this folder locally for testing.

    Example:
        .\serve.ps1
        .\serve.ps1 -Port 8080
#>
[CmdletBinding()]
param(
    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

$python = "C:\Projects\TG-Proxy-Hub\.venv\Scripts\python.exe"
if (-not (Test-Path -LiteralPath $python)) {
    $python = "python"
}

Write-Host "[INFO] serving $root"
Write-Host "[INFO] open http://127.0.0.1:$Port/   (Ctrl+C to stop)"

Push-Location $root
try {
    & $python -m http.server $Port --bind 127.0.0.1
}
finally {
    Pop-Location
}

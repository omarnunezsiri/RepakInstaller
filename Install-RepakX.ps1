# Install-RepakX.ps1
# Downloads the latest Repak-X Windows release from GitHub,
# extracts all contents into %LocalAppData%\Repak-X\,
# and creates a Start Menu shortcut so it's searchable.

$ErrorActionPreference = "Stop"

# Config
$repo = "XzantGaming/Repak-X"
$apiUrl = "https://api.github.com/repos/$repo/releases/latest"
$installDir = Join-Path $env:LOCALAPPDATA "Repak-X"
$startMenuPath = [Environment]::GetFolderPath("Programs")
$shortcutPath = Join-Path $startMenuPath "Repak-X.lnk"
$tempDir = Join-Path $env:TEMP "RepakX-Install"

Write-Host ""
Write-Host "=== Repak-X Installer ===" -ForegroundColor Cyan
Write-Host ""

# 1. Fetch latest release metadata from the GitHub API
Write-Host "[1/5] Fetching latest release info..." -ForegroundColor Yellow
$release = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" }
Write-Host "      Latest version: $($release.tag_name)" -ForegroundColor Green

# 2. Find the Windows zip asset (e.g. Repak-X-v1.4.3-Windows.zip)
Write-Host "[2/5] Locating Windows zip asset..." -ForegroundColor Yellow
$asset = $release.assets | Where-Object { $_.name -like "*Windows*.zip" } | Select-Object -First 1

if (-not $asset) {
	Write-Error "No Windows zip found in the latest release assets. Aborting."
	exit 1
}
Write-Host "      Found: $($asset.name)" -ForegroundColor Green

# 3. Download the zip to a temp folder
Write-Host "[3/5] Downloading $($asset.name)..." -ForegroundColor Yellow
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null

$zipPath = Join-Path $tempDir $asset.name
Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -UseBasicParsing
Write-Host "      Download complete." -ForegroundColor Green

# 4. Extract the zip
Write-Host "[4/5] Extracting archive..." -ForegroundColor Yellow
$extractDir = Join-Path $tempDir "extracted"
Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

# If the zip wraps everything in a single sub-folder, step into it
$topLevel = Get-ChildItem -Path $extractDir
$sourceDir = if ($topLevel.Count -eq 1 -and $topLevel[0].PSIsContainer) {
	$topLevel[0].FullName
}
else {
	$extractDir
}

Write-Host "      Extracted $(( Get-ChildItem $sourceDir -Recurse -File ).Count) files." -ForegroundColor Green

# 5. Copy everything to %LocalAppData%\Repak-X\
Write-Host "[5/5] Installing files and creating shortcut..." -ForegroundColor Yellow

if (Test-Path $installDir) { Remove-Item $installDir -Recurse -Force }
New-Item -ItemType Directory -Path $installDir | Out-Null
Copy-Item -Path "$sourceDir\*" -Destination $installDir -Recurse -Force

# Find the main .exe in the installed folder
$exe = Get-ChildItem -Path $installDir -Filter "*.exe" -Recurse | Select-Object -First 1
if (-not $exe) {
	Write-Error "No .exe found after extraction. Aborting."
	exit 1
}

# Create a .lnk shortcut in Start Menu pointing at the exe
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exe.FullName
$shortcut.WorkingDirectory = $installDir
$shortcut.Description = "Repak-X"
$shortcut.Save()

Remove-Item $tempDir -Recurse -Force

Write-Host ""
Write-Host "Done! Repak-X $($release.tag_name) is installed." -ForegroundColor Green
Write-Host "Files    : $installDir" -ForegroundColor White
Write-Host "Shortcut : $shortcutPath" -ForegroundColor White
Write-Host "Tip      : Press Win and type 'Repak-X' to launch it." -ForegroundColor DarkGray
Write-Host ""

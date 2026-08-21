# build.ps1 - builds the portable Expanto release zip into dist\.
# Downloads the toolchain (Ahk2Exe, AutoHotkey v2 base) into build\ on first
# run and caches it there. Works in Windows PowerShell 5.1 and PowerShell 7
# (used by the GitHub Actions release workflow).
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$root = $PSScriptRoot
$tools = Join-Path $root 'build'
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $tools | Out-Null

# version from the script header ("; Expanto - vX.Y.Z ...")
$header = (Get-Content (Join-Path $root 'Expanto.ahk') -TotalCount 5) -join ' '
$version = if ($header -match 'v(\d+\.\d+\.\d+)') { $Matches[1] } else { '0.0.0' }
Write-Host "Building Expanto $version"

$ahk2exe = Join-Path $tools 'compiler\Ahk2Exe.exe'
if (-not (Test-Path $ahk2exe)) {
    Write-Host 'Downloading Ahk2Exe...'
    $rel = Invoke-RestMethod 'https://api.github.com/repos/AutoHotkey/Ahk2Exe/releases/latest'
    $asset = $rel.assets | Where-Object { $_.name -like '*.zip' } | Select-Object -First 1
    Invoke-WebRequest $asset.browser_download_url -OutFile (Join-Path $tools 'ahk2exe.zip')
    Expand-Archive (Join-Path $tools 'ahk2exe.zip') (Join-Path $tools 'compiler') -Force
}

$base = Join-Path $tools 'base\AutoHotkey64.exe'
if (-not (Test-Path $base)) {
    Write-Host 'Downloading AutoHotkey v2 base...'
    $rels = Invoke-RestMethod 'https://api.github.com/repos/AutoHotkey/AutoHotkey/releases'
    $v2 = $rels | Where-Object { $_.tag_name -like 'v2.0*' } | Select-Object -First 1
    $asset = $v2.assets | Where-Object { $_.name -like 'AutoHotkey_2*.zip' } | Select-Object -First 1
    Invoke-WebRequest $asset.browser_download_url -OutFile (Join-Path $tools 'ahk2.zip')
    Expand-Archive (Join-Path $tools 'ahk2.zip') (Join-Path $tools 'base') -Force
}

# clear dist with retries - sync clients/AV can hold freshly written files briefly
if (Test-Path $dist) {
    $cleared = $false
    foreach ($i in 1..5) {
        try {
            Remove-Item $dist -Recurse -Force -ErrorAction Stop
            $cleared = $true
            break
        } catch {
            Start-Sleep -Seconds 2
        }
    }
    if (-not $cleared) { throw "Could not clear $dist - is Expanto.exe running or the folder open?" }
}
New-Item -ItemType Directory -Force (Join-Path $dist 'lib') | Out-Null

$p = Start-Process -FilePath $ahk2exe -ArgumentList "/in `"$(Join-Path $root 'Expanto.ahk')`" /out `"$(Join-Path $dist 'Expanto.exe')`" /base `"$base`" /icon `"$(Join-Path $root 'app.ico')`" /silent verbose" -Wait -PassThru -WindowStyle Hidden
if ($p.ExitCode -ne 0 -or -not (Test-Path (Join-Path $dist 'Expanto.exe'))) {
    throw "Ahk2Exe failed (exit code $($p.ExitCode))"
}
Write-Host 'Compiled Expanto.exe'

# Runtime files the exe needs beside it. NOTE: only WebView2Loader.dll from lib\ -
# never copy lib\ wholesale (words_private\ and downloaded word lists live there).
Copy-Item (Join-Path $root 'ui') (Join-Path $dist 'ui') -Recurse
Copy-Item (Join-Path $root 'lib\WebView2Loader.dll') (Join-Path $dist 'lib')
Copy-Item (Join-Path $root 'app.ico') $dist
Copy-Item (Join-Path $root 'reposettings.ini') $dist
Copy-Item (Join-Path $root 'README.md') $dist
Copy-Item (Join-Path $root 'LICENSE') $dist
Copy-Item (Join-Path $root 'THIRD-PARTY.txt') $dist

$zip = Join-Path $dist "Expanto-$version.zip"
$contents = @('Expanto.exe', 'ui', 'lib', 'app.ico', 'reposettings.ini', 'README.md', 'LICENSE', 'THIRD-PARTY.txt') | ForEach-Object { Join-Path $dist $_ }
Compress-Archive -Path $contents -DestinationPath $zip -Force
Write-Host "Done: $zip"

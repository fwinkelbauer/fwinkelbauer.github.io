---
title: "Creating a Standalone Offline Chocolatey Installer"
date: 2019-09-27
---

The [Chocolatey install documentation][choco_msi] includes a section about why
there isn't an MSI to install Chocolatey. In case that you are still searching
for an executable, this post outlines a way to create your own "setup" using a
self extracting [7-zip][7z] archive. We'll need the following directory
structure:

- `config.txt`: A 7-zip configuration file
- `install.bat`: A wrapper script to call `install.ps1`
- `install.ps1`: This script will perform the actual installation inside the
  7-zip archive
- `build.ps1`: The script which will create our target file `output/chocolateySetup.exe`

## config.txt

We're using a rather simple configuration, which will:

- Show the user a "Do you want to install Chocolatey?" yes/no prompt
- Run `install.bat` after extracting the archive

The [7-zip SFX documentation][doc_sfx] outlines all available format options of
a `config.txt` file.

``` text
;!@Install@!UTF-8!
Title="Chocolatey"
BeginPrompt="Do you want to install Chocolatey?"
ExecuteFile="install.bat"
;!@InstallEnd@!
```

## install.bat

`install.bat` is a simple wrapper script which calls `install.ps1`. I found this
to be more convenient than trying to let the 7-zip SFX module call PowerShell directly.

``` batchfile
@ECHO OFF
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dpn0.ps1'"
PAUSE
```

## install.ps1

This script performs the actual installation by calling Chocolatey's
`chocolateyInstall.ps1`.

``` powershell
if ($env:ChocolateyInstall) {
    Write-Warning 'Chocolatey is already installed!'
    return
}

$env:ChocolateyInstall = "$($env:ProgramData)\chocolatey"

& (Join-Path $PSScriptRoot 'chocolatey\tools\chocolateyInstall.ps1')
```

## build.ps1

This script does a few things for us. It will:

- Download Chocolatey (v0.10.13) and extract it in a `temp` directory
- Download and extract the 7-zip SFX module in a `temp` directory
- Create the 7-zip archive `output\chocolateySetup.7z` containing Chocolatey,
  `install.ps1` and `install.bat`
- And finally, create the executable `output/chocolateySetup.exe` by combining
  `output/chocolateySetup.7z`, `config.txt` and the 7-zip SFX module

All calls to 7-zip are wrapped in an `exec` function, which I've described in a
previous [post][fw_provision].

You can tweak the `$chocoUrl` parameter to download a different version of
Chocolatey. Keep in mind that you might need to delete the `temp` directory to
remove all "cached" files.

``` powershell
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 'Latest'

function exec {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        [int[]]$ValidExitCodes = @(0)
    )

    $global:LASTEXITCODE = 0

    & $ScriptBlock

    if (-not ($global:LASTEXITCODE -in $ValidExitCodes)) {
        throw "Invalid exit code: $($global:LASTEXITCODE)"
    }
}

$configFile = Join-Path $PSScriptRoot 'config.txt'
$chocoUrl = 'https://chocolatey.org/api/v2/package/chocolatey/0.10.13'
$lzmaUrl = 'https://www.7-zip.org/a/lzma1900.7z'

$outputDir = Join-Path $PSScriptRoot 'output'
$tempDir = Join-Path $PSScriptRoot 'temp'
$installerFile = Join-Path $outputDir 'chocolateySetup.exe'

if (Test-Path $outputDir) {
    Remove-Item $outputDir -Recurse -Force
}

New-Item $outputDir -Type Directory -Force | Out-Null
New-Item $tempDir -Type Directory -Force | Out-Null

$chocoDir = Join-Path $tempDir 'chocolatey'

if (-not (Test-Path $chocoDir)) {
    $chocoZipFile = Join-Path $tempDir 'chocolatey.zip'
    Invoke-WebRequest -Uri $chocoUrl -OutFile $chocoZipFile
    Expand-Archive -Path $chocoZipFile -DestinationPath $chocoDir
}

$sfxFileName = '7zS2.sfx'
$sfxFile = Join-Path $tempDir $sfxFileName

if (-not (Test-Path $sfxFile)) {
    $lzmaFile = Join-Path $tempDir 'lzma.7z'
    Invoke-WebRequest -Uri $lzmaUrl -OutFile $lzmaFile
    exec { 7z e $lzmaFile $sfxFileName -r -o"$tempDir" }
}

$installerZipFile = Join-Path $outputDir 'chocolateySetup.7z'

exec { 7z a $installerZipFile (Resolve-Path $chocoDir) }
exec { 7z a $installerZipFile 'install.bat' }
exec { 7z a $installerZipFile 'install.ps1' }

Get-Content $sfxFile, $configFile, $installerZipFile -Encoding Byte -Read 512 | Set-Content $installerFile -Encoding Byte
```

## Usage

Given the above files, call `build.ps1` to create `output\chocolateySetup.exe`.
Run the setup file, confirm the UAC prompt and the "Do you want to install Chocolatey?"
dialog to start the install process.

There's currently only one drawback that I'm aware of: After running the
installer, Windows might pop up a "This program might not have installed
correctly", even if the overall installation might be successful. Others have
reported the similar problems on [superuser][superuser_sfx] and
[stackoverflow][stackoverflow_sfx].

[choco_msi]: https://chocolatey.org/docs/installation#why-isnt-there-an-msi
[7z]: https://www.7-zip.org/
[doc_sfx]: https://sevenzip.osdn.jp/chm/cmdline/switches/sfx.htm
[fw_provision]: https://florianwinkelbauer.com/posts/2019-01-21-powershell-provision/
[superuser_sfx]: https://superuser.com/questions/730242/7zip-self-extracting-executables-require-admin-privileges-and-trigger-compatib
[stackoverflow_sfx]: https://stackoverflow.com/questions/9229581/how-to-do-vista-uac-aware-self-extract-installer

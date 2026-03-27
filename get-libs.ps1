param(
    [Parameter(Position = 0)]
    [string]$SmeDepsVersion = "skip",
    [Parameter(Position = 1)]
    [string]$SmeDepsCommonVersion = "skip",
    [Parameter(Position = 2)]
    [string]$SmeDepsQtVersion = "skip",
    [Parameter(Position = 3)]
    [string]$SmeDepsLlvmVersion = "skip",
    [Parameter(Position = 4)]
    [string]$BuildTag = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

if ($env:RUNNER_OS -ne "Windows") {
    throw "Unsupported runner combination: $($env:RUNNER_OS)/$($env:RUNNER_ARCH)"
}

switch ($env:RUNNER_ARCH) {
    "X64" {
        $os = "win64"
    }
    "ARM64" {
        $os = "win64-arm64"
    }
    default {
        throw "Unsupported runner combination: $($env:RUNNER_OS)/$($env:RUNNER_ARCH)"
    }
}

$installPrefix = if ($env:INSTALL_PREFIX) { $env:INSTALL_PREFIX } else { "c:\smelibs" }
$installPrefix = $installPrefix.Replace("\", "/")
$haveFilesToInstall = $false

function Get-ReleaseUrl {
    param(
        [string]$Dep,
        [string]$Version
    )

    if ($Version -eq "latest") {
        return "https://github.com/spatial-model-editor/$Dep/releases/latest/download/${Dep}_${os}${BuildTag}.tgz"
    }

    return "https://github.com/spatial-model-editor/$Dep/releases/download/$Version/${Dep}_${os}${BuildTag}.tgz"
}

function Install-Dependency {
    param(
        [string]$Dep,
        [string]$Version
    )

    if ($Version -eq "skip") {
        Write-Host "Skipping $Dep download"
        return
    }

    $archiveName = "${Dep}_${os}${BuildTag}.tgz"
    $url = Get-ReleaseUrl -Dep $Dep -Version $Version

    Write-Host "Downloading $Version $Dep$BuildTag for $os"
    Invoke-WebRequest -Uri $url -OutFile $archiveName
    tar -xf $archiveName
    Remove-Item -Path $archiveName -Force
    $script:haveFilesToInstall = $true
}

function Resolve-StagedInstallPath {
    param(
        [string]$InstallPrefix
    )

    $installPrefixWindows = $InstallPrefix.Replace("/", "\")
    $candidates = [System.Collections.Generic.List[string]]::new()

    if ($InstallPrefix -match "^[A-Za-z]:/") {
        $driveLetter = $InstallPrefix.Substring(0, 1).ToLowerInvariant()
        $rest = $InstallPrefix.Substring(3).Replace("/", "\")
        if ($rest.Length -gt 0) {
            $candidates.Add((Join-Path $PWD.Path (Join-Path $driveLetter $rest)))
        }
    }

    $leaf = Split-Path -Leaf $installPrefixWindows
    if ($leaf) {
        $candidates.Add((Join-Path $PWD.Path $leaf))
    }

    $candidates.Add($installPrefixWindows)

    foreach ($candidate in ($candidates | Select-Object -Unique)) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw "Could not find extracted install tree for $InstallPrefix after unpacking dependency archives"
}

Install-Dependency -Dep "sme_deps" -Version $SmeDepsVersion
Install-Dependency -Dep "sme_deps_common" -Version $SmeDepsCommonVersion
Install-Dependency -Dep "sme_deps_qt" -Version $SmeDepsQtVersion
Install-Dependency -Dep "sme_deps_llvm" -Version $SmeDepsLlvmVersion

if ($haveFilesToInstall) {
    $installPrefixWindows = $installPrefix.Replace("/", "\")
    $stagedInstallPath = Resolve-StagedInstallPath -InstallPrefix $installPrefix
    $resolvedStagedInstallPath = (Resolve-Path $stagedInstallPath).Path

    $installParent = Split-Path -Parent $installPrefixWindows
    if ($installParent) {
        New-Item -ItemType Directory -Force -Path $installParent | Out-Null
    }

    if (Test-Path $installPrefixWindows) {
        $resolvedInstallPrefix = (Resolve-Path $installPrefixWindows).Path
        if (-not [string]::Equals($resolvedInstallPrefix, $resolvedStagedInstallPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -Path $installPrefixWindows -Recurse -Force
        }
    }

    if (-not (Test-Path $installPrefixWindows)) {
        Move-Item -Path $stagedInstallPath -Destination $installPrefixWindows
    }
}

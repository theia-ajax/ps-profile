$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

function Enable-VCEnv($version) {
    $vc_version = "-latest";
    if ($version -eq "2019") {
        $vc_version = "-version 16";
    }
    elseif ($version -eq "2017") {
        $vc_version = "-version 15";
    }

    $vswhere_path = "vswhere.exe"

    if (!(Get-Command $vswhere_path -ErrorAction SilentlyContinue)) {
        # Try to find vswhere in visual studio install location
        $vswhere_path = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe";
        if (!(Test-Path -LiteralPath $vswhere_path -PathType Leaf)) {
            # Try to find in chocolatey install location
            $vswhere_path = "${env:ProgramData}\chocolatey\lib\vswhere\tools\vswhere.exe";
        }
        if (!(Test-Path -LiteralPath $vswhere_path -PathType Leaf)) {
            # Give up
            Write-Output "Unable to find vswhere.exe";
            exit;
        }
    }

    Write-Output "Using vswhere.exe located at ""$vswhere_path""";

    $vswhere_path = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe";
    $vswhere_cmd = "& ""$vswhere_path"" {0} -property installationPath" -f $vc_version;

    Write-Host $vswhere_cmd
    $vswhere_result = Invoke-Expression $vswhere_cmd;

    if ($vswhere_result -is [array]) {
        $vswhere_result = $vswhere_result[0];
    }

    Write-Host $vc_version
    Write-Host $vswhere_result

    $vcvarsall_path = """{0}\VC\Auxiliary\Build\vcvarsall.bat""" -f $vswhere_result

    cmd /c "$vcvarsall_path amd64&set" |
    ForEach-Object {
        if ($_ -match "=") {
            $v = $_.split("="); set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
        }
        Write-Host $_
    }
}

function Get-Git-Status() { git status }
function p8() { Push-Location $env:PICO8_DIR }

$env:PICO8_DIR = "$env:APPDATA\pico-8\carts"

Set-Alias subl 'C:\Program Files\Sublime Text 3\sublime_text.exe'
Set-Alias gs Get-Git-Status

Import-Module posh-git

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

function Enable-VCEnv() {
    pushd "$env:VSSDK140Install\..\VC\"
    cmd /c "vcvarsall.bat amd64&set" |
    foreach {
        if ($_ -match "=") {
            $v = $_.split("="); set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
        }
    }
    popd

    Write-Host "Visual Studio 2015 Command Prompt variables set." -ForegroundColor Yellow
}

Enable-VCEnv

function Get-Git-Status() { git status }

Set-Alias subl 'C:\Program Files\Sublime Text 3\sublime_text.exe'
Set-Alias gs Get-Git-Status

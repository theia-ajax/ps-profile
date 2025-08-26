# Place at <path to cmder>/cmder/config/user_profile.ps1
# Typically ~/bin/cmder/config/user_profile.ps1
# Use this file to run your own startup commands

## Prompt Customization
<#
.SYNTAX
    <PrePrompt><CMDER DEFAULT>
    λ <PostPrompt> <repl input>
.EXAMPLE
    <PrePrompt>N:\Documents\src\cmder [master]
    λ <PostPrompt> |
#>

[ScriptBlock]$PrePrompt = {

}

# Replace the cmder prompt entirely with this.
# [ScriptBlock]$CmderPrompt = {}

[ScriptBlock]$PostPrompt = {

}

## <Continue to add your own>

# # Delete default powershell aliases that conflict with bash commands
# if (get-command git) {
#     del -force alias:cat
#     del -force alias:clear
#     del -force alias:cp
#     del -force alias:diff
#     del -force alias:echo
#     del -force alias:kill
#     del -force alias:ls
#     del -force alias:mv
#     del -force alias:ps
#     del -force alias:pwd
#     del -force alias:rm
#     del -force alias:sleep
#     del -force alias:tee
# }


function Enable-VCEnv($version) {
    $vc_version = "-latest"
    if ($version -eq "2022") {
        $vc_version = "-version 17"
    }
    elseif ($version -eq "2019") {
        $vc_version = "-version 16"
    }
    elseif ($version -eq "2017") {
        $vc_version = "-version 15"
    }

    $vswhere_path = "vswhere.exe"

    if (!(Get-Command $vswhere_path -ErrorAction SilentlyContinue)) {
        # Try to find vswhere in visual studio install location
        $vswhere_path = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
        if (!(Test-Path -LiteralPath $vswhere_path -PathType Leaf)) {
            # Try to find in chocolatey install location
            $vswhere_path = "${env:ProgramData}\chocolatey\lib\vswhere\tools\vswhere.exe"
        }
        if (!(Test-Path -LiteralPath $vswhere_path -PathType Leaf)) {
            # Give up
            Write-Output "Unable to find vswhere.exe"
            exit
        }
    }

    Write-Output "Using vswhere.exe located at ""$vswhere_path"""

    $vswhere_path = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
    $vswhere_cmd = "& ""$vswhere_path"" {0} -property installationPath" -f $vc_version

    Write-Host $vswhere_cmd
    $vswhere_result = Invoke-Expression $vswhere_cmd

    if ($vswhere_result -is [array]) {
        $vswhere_result = $vswhere_result[0]
    }

    Write-Host $vc_version
    Write-Host $vswhere_result

    $vcvarsall_path = """{0}\VC\Auxiliary\Build\vcvarsall.bat""" -f $vswhere_result

    cmd /c "$vcvarsall_path amd64&set" |
    ForEach-Object {
        if ($_ -match "=") {
            $v = $_.split("=")
            set-item -force -path "ENV:\$($v[0])" -value "$($v[1])"
        }
        Write-Host $_
    }
}

function Get-Git-Status() { git status }
function p8() { Push-Location $env:PICO8_DIR }

function Remove-ItemProxy() {
    [CmdletBinding(DefaultParameterSetName = 'Path', SupportsShouldProcess = $true, ConfirmImpact = 'Medium', SupportsTransactions = $true, HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=113373')]
    param(
        [Parameter(ParameterSetName = 'Path', Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${Path},

        [Parameter(ParameterSetName = 'LiteralPath', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('PSPath')]
        [string[]]
        ${LiteralPath},

        [string]
        ${Filter},

        [string[]]
        ${Include},

        [string[]]
        ${Exclude},

        [switch]
        ${Recurse},

        [switch]
        ${Force},

        [Alias('RF')]
        [switch]
        $RecurseForce,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential})


    dynamicparam {
        try {
            $PSBoundParameters.Remove('RecurseForce') | Out-Null
            $targetCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Remove-Item', [System.Management.Automation.CommandTypes]::Cmdlet, $PSBoundParameters)
            $dynamicParams = @($targetCmd.Parameters.GetEnumerator() | Microsoft.PowerShell.Core\Where-Object { $_.Value.IsDynamic })
            if ($dynamicParams.Length -gt 0) {
                $paramDictionary = [Management.Automation.RuntimeDefinedParameterDictionary]::new()
                foreach ($param in $dynamicParams) {
                    $param = $param.Value

                    if (-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Name)) {
                        $dynParam = [Management.Automation.RuntimeDefinedParameter]::new($param.Name, $param.ParameterType, $param.Attributes)
                        $paramDictionary.Add($param.Name, $dynParam)
                    }
                }
                return $paramDictionary
            }
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    begin {
        try {
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Remove-Item', [System.Management.Automation.CommandTypes]::Cmdlet)
            if ($RecurseForce) {
                $scriptCmd = { & $wrappedCmd @PSBoundParameters -Recurse -Force }
            }
            else {
                $scriptCmd = { & $wrappedCmd @PSBoundParameters }
            }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    process {
        try {
            $steppablePipeline.Process($_)
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    end {
        try {
            $steppablePipeline.End()
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    <#

.ForwardHelpTargetName Microsoft.PowerShell.Management\Remove-Item
.ForwardHelpCategory Cmdlet

#>
}

function Set-LocationCommand() {
    [CmdletBinding(DefaultParameterSetName = 'Command')]
    param(
        [Parameter(ParameterSetName = 'Command', Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        ${Command}
    )
    Get-Command $Command | Select-Object -ExpandProperty Source | Split-Path | Set-Location
}

$env:PICO8_DIR = "$env:APPDATA\pico-8\carts"

Set-Alias subl 'C:\Program Files\Sublime Text 3\sublime_text.exe'
Set-Alias gs Get-Git-Status

Set-Alias rm Remove-ItemProxy -force -option 'Constant','AllScope'
Set-Alias cdcmd Set-LocationCommand

Import-Module posh-git

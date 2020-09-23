<#PSScriptInfo
    .VERSION
        0.0.2
    .GUID
        3751b890-2eed-413b-976f-e4becb9170f8
    .AUTHOR
        Baptiste Cabrera
    .COMPANYNAME
        Bca
    .COPYRIGHT
        (c) 2020 Bca. All rights reserved.
    .TAGS
        markdown documentation Linux Windows MacOS
    .LICENSEURI 
        https://github.com/baptistecabrera/bca-savemarkdowncommanddocumentation/blob/master/LICENSE
    .PROJECTURI 
        https://github.com/baptistecabrera/bca-savemarkdowncommanddocumentation
    .ICONURI 
        https://www.powershellgallery.com/Content/Images/Branding/packageDefaultIcon.png
    .EXTERNALMODULEDEPENDENCIES 
    .REQUIREDSCRIPTS 
    .EXTERNALSCRIPTDEPENDENCIES 
    .RELEASENOTES
        - Some format enhancements
#>

<#
    .SYNOPSIS
        Saves help in markdown format.
    .DESCRIPTION
        Saves commands help in markdown format, using info from Get-Help, Get-Command, Test-ScriptFileInfo (if a script is specified) and Get-Module (if a module is specified).
    .PARAMETER ModuleName
        A string containing the name of the module.
        The module name must be listable, already imported, or the ModulePath must be specified.
    .PARAMETER ModulePath
        A string containing the path of the module file.
    .PARAMETER ScriptPath
        A string containing the path of the script file.
    .PARAMETER Path
        A string containing the output folder path.
    .PARAMETER OutputLayout
        A string containing the output layout.
        - 'OneFilePerCommand' will save one file per command named ReadMe.md
        - 'OneFilePerCommandWithIndex' will save one index file named ReadMe.md that lists the commands and link to them, and one file per command named after the command and placed under a subloder named 'commands'.
    .EXAMPLE
        .\Save-MarkdownCommandDocumentation.ps1 -ScriptPath C:\MyProject\MyScript.ps1 -OutputLayout OneFilePerCommand -Path C:\MyProject\doc

        Description
        -----------
        This example will save a command file from C:\MyProject\MyScript.ps1 in C:\MyProject\doc.
    .EXAMPLE
        .\Save-MarkdownCommandDocumentation.ps1 -ModuleName MyModule -OutputLayout OneFilePerCommandWithIndex -Path C:\MyProject\doc

        Description
        -----------
        This example will save an index of the commands exported by the module MyModule, and one file per command in C:\MyProject\doc.
    .EXAMPLE
        .\Save-MarkdownCommandDocumentation.ps1 -ModulePath C:\MyProkect\MyModule\MyModule.psd1 -OutputLayout OneFilePerCommandWithIndex -Path C:\MyProject\doc

        Description
        -----------
        This example will save an index of the commands exported by the module MyModule from path C:\MyProkect\MyModule\MyModule.psd1, and one file per command in C:\MyProject\doc.
    .NOTES
        If you have no comment-based help and no command manifest (ModuleManifest or ScriptFileInfo), the documentation will be limited.
#>
[CmdletBinding()]
param (
    [Parameter(ParameterSetName = "FromModulePath", Mandatory = $false)]
    [Parameter(ParameterSetName = "FromModuleName", Mandatory = $true)]
    [string] $ModuleName,
    [Parameter(ParameterSetName = "FromModulePath", Mandatory = $true)]
    [string] $ModulePath,
    [Parameter(ParameterSetName = "FromScriptPath", Mandatory = $true)]
    [ValidateScript( {Test-Path $_  } )]
    [string] $ScriptPath,
    [Parameter(ParameterSetName = "FromModulePath", Mandatory = $false)]
    [Parameter(ParameterSetName = "FromModuleName", Mandatory = $false)]
    [Parameter(ParameterSetName = "FromScriptPath", Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript( { Test-Path $_ } )]
    [string] $Path = $PSScriptRoot,
    [Parameter(ParameterSetName = "FromModulePath", Mandatory = $false)]
    [Parameter(ParameterSetName = "FromModuleName", Mandatory = $false)]
    [Parameter(ParameterSetName = "FromScriptPath", Mandatory = $false)]
    [ValidateSet("OneFilePerCommand", "OneFilePerCommandWithIndex")]
    [string] $OutputLayout = "OneFilePerCommand"
)

begin
{
    $CommandPath = $Path
    switch -Regex ($PSCmdlet.ParameterSetName)
    {
        "FromModule"
        {
            $Modules = Get-Module
            if ($ModulePath)
            {
                Import-Module $ModulePath -Force
                if (!$ModuleName) { $ModuleName = (Split-Path $ModulePath -Leaf).Replace(".psd1", "").Replace(".psm1", "") }
            }
            $Parent = Get-Module -Name $ModuleName
            $Command = Get-Command -Module $ModuleName
        }
        "FromScriptPath"
        {
            try { $Parent = Test-ScriptFileInfo -Path $ScriptPath }
            catch {}
            $Command = Get-Command $ScriptPath
        }
    }

    if ($OutputLayout -eq "OneFilePerCommandWithIndex")
    {
        $IndexFile = Join-Path $Path "ReadMe.md"
        $CommandPath = Join-Path $Path "commands"
        If (!(Test-Path $CommandPath)) { New-Item -Path $CommandPath -ItemType Directory -Force | Out-Null }

        '# {0} `{1}`' -f $Parent.Name, $Parent.Version | Set-Content -Path $IndexFile
        if ($Parent.Tags) { 'Tags: `{0}`' -f (($Parent.Tags | Sort-Object -Unique) -join '` `') | Add-Content -Path $IndexFile }
        if ($Parent.PowerShellVersion) { "`r`n`Minimum PowerShell version: ``{0}``" -f $Parent.PowerShellVersion | Add-Content -Path $IndexFile }
        "`r`n{0}" -f $Parent.Description | Add-Content -Path $IndexFile
        "`r`n## Commands" | Add-Content -Path $IndexFile
    }

    if ($Host.UI.RawUI)
    {
        $rawUI = $Host.UI.RawUI
        $oldSize = $rawUI.BufferSize
        $typeName = $oldSize.GetType().FullName
        $newSize = New-Object $typeName (500, $oldSize.Height)
        $rawUI.BufferSize = $newSize
    }
}
process
{
    $Command | ForEach-Object {
        $CurrentCommand = $_
        
        if ($CurrentCommand.CommandType -eq "ExternalScript") { $Help = Get-Help $CurrentCommand.Path -Full }
        Else { $Help = Get-Help $CurrentCommand.Name -Full }
        $CommandFile = Join-Path $CommandPath ("{0}.md" -f $CurrentCommand.Name)
        
        $CommandNameHeader = '# {0}' -f $CurrentCommand.Name
        if ($Parent.Version) { $CommandNameHeader += ' `{0}`' -f $Parent.Version }
        
        $CommandNameHeader | Set-Content -Path $CommandFile
        if ($OutputLayout -ne "OneFilePerCommandWithIndex") 
        {
            if ($Parent.Tags) { 'Tags: `{0}`' -f (($Parent.Tags | Sort-Object -Unique) -join '` `') | Add-Content -Path $CommandFile }
            if ($Parent.PowerShellVersion) { "`r`nMinimum PowerShell Version: ``{0}``" -f $Parent.PowerShellVersion | Add-Content -Path $CommandFile }
        }
        else { ("# {0}" -f $CurrentCommand.Name) | Set-Content -Path $CommandFile }
        "`r`nType: {0}" -f $CurrentCommand.CommandType | Add-Content -Path $CommandFile 

        if ($CurrentCommand.ModuleName) { ("`r`nModule: [{0}]({1})" -f $CurrentCommand.ModuleName, "../ReadMe.md") | Add-Content -Path $CommandFile }
        if ($OutputLayout -eq "OneFilePerCommandWithIndex") { ("- [{0}](commands/{0}.md)" -f $CurrentCommand.Name) | Add-Content -Path $IndexFile }

        if ($Help.Synopsis -notlike "$($Help.Name)*") { "`r`n{0}" -f $Help.Synopsis | Add-Content $CommandFile }
        if ($Help.Description)
        { 
            "## Description" | Add-Content -Path $CommandFile
            ($Help.Description | Out-String).Trim() | Add-Content $CommandFile
        }

        "## Syntax" | Add-Content -Path $CommandFile
        $CurrentCommand.ParameterSets | ForEach-Object {
            if ($_.Name -ne "__AllParameterSets")
            { 
                $ParameterSetTitle = "### {0}" -f $_.Name
                if ($_.IsDefault) { $ParameterSetTitle += " (default)" }
                $ParameterSetTitle | Add-Content $CommandFile
            }
            "``````powershell`r`n{0} {1}`r`n``````" -f $CurrentCommand.Name, $_.ToString() | Add-Content $CommandFile
        }

        if ($Help.examples)
        {
            "## Examples" | Add-Content -Path $CommandFile
            $Help.examples.example | ForEach-Object {
                $Title = $_.title.Replace("EXAMPLE", "Example").Replace("-------------------------- ", "").Replace(" --------------------------", "")
                ("### {0}" -f $Title) | Add-Content -Path $CommandFile
                $Example = "{0}`r`n{1}" -f $_.code, ($_.remarks | Out-String).Trim()
                $Code = ($Example -split "`r`nDescription`r`n-----------`r`n")[0]
                $Description = ($Example -split "`r`nDescription`r`n-----------`r`n")[1]
                "``````powershell`r`n{0}`r`n```````r`n{1}" -f $Code, $Description | Add-Content -Path $CommandFile
            }
        }

        if ($CurrentCommand.Parameters) 
        {
            "## Parameters" | Add-Content -Path $CommandFile
            $CurrentCommand.Parameters.Keys | Where-Object { $CurrentCommand.Parameters.$_.Name -notin ([System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters) } | ForEach-Object {
                $ParameterMd = @()
                $CommandParameter = $CurrentCommand.Parameters.$_
                $HelpParameter = $Help.parameters.parameter | Where-Object { $_.name -eq $CommandParameter.Name }
                $Obsolete = $CommandParameter.Attributes | Where-Object { $_.TypeId.Name -eq "ObsoleteAttribute" }
                $ParameterAttribute = $CommandParameter.Attributes | Where-Object { $_.TypeId.Name -eq "ParameterAttribute" }
                $ParameterSetAttributesMd = @()
                $ParameterAttribute | ForEach-Object { 
                    $AcceptPipeline = $false
                    if ($_.ValueFromPipelineByPropertyName -or $_.ValueFromPipeline) { $AcceptPipeline = $true }
                    $_ | Add-Member -MemberType NoteProperty -Name AcceptPipeline -Value $AcceptPipeline -PassThru -Force | Out-Null
                }
                
                $ParameterMd += '### `-{0}`' -f $CommandParameter.Name
                if ($Obsolete) { $ParameterMd += ":warning: This parameter is obsolete: {0}" -f $Obsolete.Message }
                if ($HelpParameter.description) { $ParameterMd += ($HelpParameter.description | Out-String).Trim() }
                $ParameterMd += "`r`n| | |"
                $ParameterMd += "|:-|:-|"
                $ParameterMd += "|Type:|{0}|" -f $CommandParameter.ParameterType.Name
                if ($CommandParameter.Aliases) { $ParameterMd += "|Aliases|{0}|" -f ($CommandParameter.Aliases -join ", ") }
                if ($HelpParameter.defaultValue) { $ParameterMd += '|Default value:|`{0}`|' -f $HelpParameter.defaultValue }
                if ($CommandParameter.ParameterSets.Keys -ne "__AllParameterSets") { $ParameterMd += "|Parameter sets:|{0}|" -f ($CommandParameter.ParameterSets.Keys -join ", ") }
                
                $PositionMd = $false
                $MandatoryMd = $false
                $PipelineMd = $false
                if (($ParameterAttribute.Position | Get-Unique).Count -le 1)
                { 
                    $Position = $ParameterAttribute.Position | Get-Unique
                    if ($Position -lt 0) { $Position = "Named" }
                    $ParameterMd += "|Position:|{0}|" -f $Position
                    $PositionMd = $true
                }
                if (($ParameterAttribute.Mandatory | Get-Unique).Count -le 1)
                { 
                    $ParameterMd += "|Required:|{0}|" -f ($ParameterAttribute.Mandatory | Get-Unique)
                    $MandatoryMd = $true
                }
                if (($ParameterAttribute.AcceptPipeline | Get-Unique).Count -le 1)
                { 
                    if (!$ParameterAttribute.AcceptPipeline)
                    { 
                        $ParameterMd += "|Accepts pipepline input:|{0}|" -f ($ParameterAttribute.AcceptPipeline | Get-Unique)
                        $PipelineMd = $true
                    }
                    elseif ((($ParameterAttribute.ValueFromPipelineByPropertyName | Get-Unique).Count -le 1) -and $ParameterAttribute.ValueFromPipelineByPropertyName[0])
                    {
                        $ParameterMd += "|Accepts pipepline input:|{0} (by property name)|" -f ($ParameterAttribute.ValueFromPipelineByPropertyName | Get-Unique)
                        $PipelineMd = $true
                    }
                    elseif (($ParameterAttribute.ValueFromPipeline | Get-Unique).Count -le 1)
                    {
                        $ParameterMd += "|Accepts pipepline input:|{0}|" -f ($ParameterAttribute.ValueFromPipeline | Get-Unique)
                        $PipelineMd = $true
                    }
                }

                $CommandParameter.Attributes | ForEach-Object {
                    $Attribute = $_
    
                    switch -Regex ($Attribute.TypeId.Name)
                    {
                        "ParameterAttribute"
                        {
                            $ParameterAttributeMd = @()
                            $Position = $Attribute.Position
                            if ($Position -lt 0) { $Position = "Named" }
                            if (!$PositionMd) { $ParameterAttributeMd += "|Position:|{0}|" -f $Position }
                            if (!$MandatoryMd) { $ParameterAttributeMd += "|Required:|{0}|" -f $Attribute.Mandatory }
                            
                            if (!$PipelineMd)
                            {
                                if (!$Attribute.ValueFromPipelineByPropertyName) { $ParameterAttributeMd += "|Accepts pipepline input:|{0}|" -f ($Attribute.AcceptPipeline | Get-Unique) }
                                else { $ParameterAttributeMd += "|Accepts pipepline input:|{0} (by property name)|" -f ($Attribute.ValueFromPipelineByPropertyName | Get-Unique) }
                            }

                            if ($Attribute.ParameterSetName -eq "__AllParameterSets") { $ParameterMd += $ParameterAttributeMd }
                            else
                            {
                                if ($ParameterAttributeMd)
                                {
                                    $ParameterSetAttributesMd += "`r`n|{0}| |" -f $Attribute.ParameterSetName
                                    $ParameterSetAttributesMd += "|:-|:-|"
                                    $ParameterSetAttributesMd += $ParameterAttributeMd
                                }
                            }
                        }
                        "^Validate.*Attribute$"
                        {
                            $Attribute | Get-Member -MemberType Property | Where-Object { $_.Name -notin "TypeId", "IgnoreCase" } | ForEach-Object {
                                $Value = $Attribute."$($_.Name)"
                                if ($Value.GetType().Name -eq "String[]") { $Value = $Value -join ", " }
                                if ($_.Name -in "ScriptBlock", "RegexPattern")
                                {
                                    $Value = '`{0}`' -f $Value.ToString().Replace("`r`n", " ")
                                    While ($Value.Contains("  ")) { $Value = $Value.Replace("  ", " ") }
                                }
                                $ParameterMd += "|Validation ({0}):|{1}|" -f $_.Name, $Value
                            }
                        }
                    }
                }
                $ParameterMd -join "`r`n" | Add-Content $CommandFile
                $ParameterSetAttributesMd -join "`r`n" | Add-Content $CommandFile
            }
            if ($CurrentCommand.Parameters.Keys -contains "WhatIf")
            {
                '### `-{0}`' -f "WhatIf" | Add-Content $CommandFile
                "This command supports the WhatIf parameter to simulate the action before executing it." | Add-Content $CommandFile
            }
            if ($CurrentCommand.Parameters.Keys -contains "Confirm")
            {
                '### `-{0}`' -f "Confirm" | Add-Content $CommandFile
                "This command supports the Confirm parameter to require a user confirmation before executing it." | Add-Content $CommandFile
            }
            if ($CurrentCommand.CmdletBinding)
            {
                '### `-{0}`' -f "<CommonParameters>" | Add-Content $CommandFile
                "This command supports the common parameters: Verbose, Debug, ErrorAction, ErrorVariable, WarningAction, WarningVariable, OutBuffer, PipelineVariable, and OutVariable.`r`nFor more information, see [about_CommonParameters](https:/go.microsoft.com/fwlink/?LinkID=113216)." | Add-Content $CommandFile
            }
        }

        if ($Help.inputTypes)
        {
            "## Inputs" | Add-Content -Path $CommandFile
            $help.inputTypes.inputType.type.name | ForEach-Object {
                "`r`n**{0}**`r`n`r`n{1}" -f $_.Split("`r`n")[0], $_.Split("`r`n")[1] | Add-Content $CommandFile
            }
        }
        if ($Help.returnValues)
        {
            "## Outputs" | Add-Content -Path $CommandFile
            $help.returnValues.returnValue.type.name | ForEach-Object {
                "`r`n**{0}**`r`n`r`n{1}" -f $_.Split("`r`n")[0], $_.Split("`r`n")[1] | Add-Content $CommandFile
            }
        }
        if ($Help.alertSet)
        {
            "## Notes" | Add-Content -Path $CommandFile
            ($Help.alertSet.alert | Out-String).Trim() | Add-Content -Path $CommandFile
        }
        if ($Help.relatedLinks.navigationLink.linkText)
        {
            "## Related Links" | Add-Content -Path $CommandFile
            $help.relatedLinks.navigationLink | Where-Object { $_ } | ForEach-Object {
                if ($_.linkText -in $Command.Name) { "- [{0}]({0}.md)" -f $_.linkText | Add-Content $CommandFile }
                elseif ($_.uri) { "- [{0}]({0})" -f $_.uri | Add-Content $CommandFile }
                else { "- {0}" -f $_.linkText | Add-Content $CommandFile }
            }
        }
    }
    if ($OutputLayout -eq "OneFilePerCommandWithIndex")
    { 
        if ($Parent.ReleaseNotes) { "`r`n## Release Notes`r`n{0}" -f $Parent.ReleaseNotes | Add-Content -Path $IndexFile }
        "---`r`n[{0}]({1})" -f $Parent.Name, $Parent.ProjectUri | Add-Content -Path $IndexFile
    }
    else { if ($Parent.ReleaseNotes) { "`r`n## Release Notes`r`n{0}" -f $Parent.ReleaseNotes | Add-Content -Path $CommandFile } }
}
end
{
    if ($Modules)
    {
        (Compare-Object -ReferenceObject $Modules -DifferenceObject (Get-Module)).InputObject  | Where-Object { $_ } | ForEach-Object {
            Remove-Module $_.Name
        }
    }
    if ($Host.UI.RawUI)
    {
        $rawUI = $Host.UI.RawUI
        $rawUI.BufferSize = $oldSize
    }
}
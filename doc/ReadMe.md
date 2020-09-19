# Save-MarkdownCommandDocumentation.ps1 `0.0.1`
Tags: `documentation` `markdown`

Type: ExternalScript

Saves help in markdown format.
## Description
Saves commands help in markdown format, using info from Get-Help, Get-Command, Test-ScriptFileInfo (if a script is specified) and Get-Module (if a module is specified).
## Syntax
### FromModuleName
```powershell
Save-MarkdownCommandDocumentation.ps1 -ModuleName <string> [-Path <string>] [-OutputLayout <string>] [<CommonParameters>]
```
### FromModulePath
```powershell
Save-MarkdownCommandDocumentation.ps1 -ModulePath <string> [-ModuleName <string>] [-Path <string>] [-OutputLayout <string>] [<CommonParameters>]
```
### FromScriptPath
```powershell
Save-MarkdownCommandDocumentation.ps1 -ScriptPath <string> [-Path <string>] [-OutputLayout <string>] [<CommonParameters>]
```
## Examples
### Example 1
```powershell
.\Save-MarkdownCommandDocumentation.ps1 -ScriptPath C:\MyProject\MyScript.ps1 -OutputLayout OneFilePerCommand -Path C:\MyProject\doc
```
This example will save a command file from C:\MyProject\MyScript.ps1 in C:\MyProject\doc.
### Example 2
```powershell
.\Save-MarkdownCommandDocumentation.ps1 -ModuleName MyModule -OutputLayout OneFilePerCommandWithIndex -Path C:\MyProject\doc
```
This example will save an index of the commands exported by the module MyModule, and one file per command in C:\MyProject\doc.
### Example 3
```powershell
.\Save-MarkdownCommandDocumentation.ps1 -ModulePath C:\MyProkect\MyModule\MyModule.psd1 -OutputLayout OneFilePerCommandWithIndex -Path C:\MyProject\doc
```
This example will save an index of the commands exported by the module MyModule from path C:\MyProkect\MyModule\MyModule.psd1, and one file per command in C:\MyProject\doc.
## Parameters
### `-ModuleName`
A string containing the name of the module.
The module name must be listable, already imported, or the ModulePath must be specified.

| | |
|:-|:-|
|Type:|String|
|Parameter sets:|FromModuleName, FromModulePath|
|Position:|Named|
|Accepts pipepline input:|False|

|FromModuleName| |
|:-|:-|
|Required:|True|

|FromModulePath| |
|:-|:-|
|Required:|False|
### `-ModulePath`
A string containing the path of the module file.

| | |
|:-|:-|
|Type:|String|
|Parameter sets:|FromModulePath|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|False|

### `-ScriptPath`
A string containing the path of the script file.

| | |
|:-|:-|
|Type:|String|
|Parameter sets:|FromScriptPath|
|Position:|Named|
|Required:|True|
|Accepts pipepline input:|False|
|Validation (ScriptBlock):|`Test-Path $_ `|

### `-Path`
A string containing the output folder path.

| | |
|:-|:-|
|Type:|String|
|Default value:|$PSScriptRoot|
|Parameter sets:|FromScriptPath, FromModuleName, FromModulePath|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|
|Validation (ScriptBlock):|` Test-Path $_ `|

### `-OutputLayout`
A string containing the output layout.
- 'OneFilePerCommand' will save one file per command named ReadMe.md
- 'OneFilePerCommandWithIndex' will save one index file named ReadMe.md that lists the commands and link to them, and one file per command named after the command and placed under a subloder named 'commands'.

| | |
|:-|:-|
|Type:|String|
|Default value:|OneFilePerCommand|
|Parameter sets:|FromScriptPath, FromModuleName, FromModulePath|
|Position:|Named|
|Required:|False|
|Accepts pipepline input:|False|
|Validation (ValidValues):|OneFilePerCommand, OneFilePerCommandWithIndex|

## Notes
If you have no comment-based help and no command manifest (ModuleManifest or ScriptFileInfo), the documentation will be limited.

## Release Notes
- First version

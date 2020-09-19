# Save-MarkdownCommandDocumentation
![Platform](https://img.shields.io/powershellgallery/p/Save-MarkdownCommandDocumentation?logo=powershell&logoColor=white) [![License: MIT](https://img.shields.io/github/license/baptistecabrera/bca-savemarkdowncommanddocumentation?logo=open-source-initiative&logoColor=white)](https://opensource.org/licenses/MIT)

[![GitHub Release](https://img.shields.io/github/v/tag/baptistecabrera/bca-savemarkdowncommanddocumentation?logo=github&logoColor=white&label=release)](https://github.com/baptistecabrera/bca-savemarkdowncommanddocumentation/releases) [![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Save-MarkdownCommandDocumentation?color=informational&logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/Save-MarkdownCommandDocumentation) [![Nuget](https://img.shields.io/nuget/v/Save-MarkdownCommandDocumentation?color=informational&logo=nuget&logoColor=white)](https://www.nuget.org/packages/Save-MarkdownCommandDocumentation/) [![Chocolatey](https://img.shields.io/chocolatey/v/bca-savemarkdowncommanddocumentation?color=informational&logo=chocolatey&logoColor=white)](https://chocolatey.org/packages/bca-savemarkdowncommanddocumentation)

## Description

_Save-MarkdownCommandDocumentation_ is a PowerShell script that helps you save your comment-based help to markdown for your scripts and modules. 

The [documentation](doc/ReadMe.md) of this script (and all my projects) has been automated with it.

## Disclaimer

- _Save-MarkdownCommandDocumentation_ has been created to answer my needs, but I provide it to people who may need such a tool.
- It may contain bugs or lack some features, in this case, feel free to open an issue, and I'll manage it as best as I can.
- This _GitHub_ repository is not the primary one, but you are welcome to contribute, see transparency for more information.

## Dependencies

_(none)_

## Examples

### Saving a script help

```powershell
.\Save-MarkdownCommandDocumentation.ps1 -ScriptPath C:\MyProject\MyScript.ps1 -OutputLayout OneFilePerCommand -Path C:\MyProject\doc
```

### Saving a module help

```powershell
.\Save-MarkdownCommandDocumentation.ps1 -ModuleName MyModule -OutputLayout OneFilePerCommandWithIndex -Path C:\MyProject\doc
```

### Saving a module manifest help

```powershell
.\Save-MarkdownCommandDocumentation.ps1 -ModulePath C:\MyProkect\MyModule\MyModule.psd1 -OutputLayout OneFilePerCommandWithIndex -Path C:\MyProject\doc
```

## Documentation
Find extended documentation [at this page](doc/ReadMe.md).

## How to install

### The easiest way

In a PowerShell console, run the following:
```powershell
Find-Script -Name Save-MarkdownCommandDocumentation | Install-Script
```

### Package

_Save-MarkdownCommandDocumentation_ is available as a package from _[PowerShell Gallery](https://www.powershellgallery.com/)_, _[NuGet](https://www.nuget.org/)_ and _[Chocolatey](https://chocolatey.org/)_*, please refer to each specific plateform on how to install the package.

\* Availability on Chocolatey is subject to approval.

### Manually

If you decide to install _Save-MarkdownCommandDocumentation_ manually, copy the script under `src` into any folder.

## Transparency

_Please not that to date I am the only developper for this module._

- All code is primarily stored on a private Git repository on Azure DevOps;
- Issues opened in GitHub create a bug in Azure DevOps; [![Sync issue to Azure DevOps](https://github.com/baptistecabrera/bca-savemarkdowncommanddocumentation/workflows/Sync%20issue%20to%20Azure%20DevOps/badge.svg)](https://github.com/baptistecabrera/bca-savemarkdowncommanddocumentation/actions?query=workflow%3A"Sync+issue+to+Azure+DevOps")
- All pushes made in GitHub are synced to Azure DevOps (that includes all branches except `master`); [![Sync branches to Azure DevOps](https://github.com/baptistecabrera/bca-savemarkdowncommanddocumentation/workflows/Sync%20branches%20to%20Azure%20DevOps/badge.svg)](https://github.com/baptistecabrera/bca-savemarkdowncommanddocumentation/actions?query=workflow%3A"Sync+branches+to+Azure+DevOps")
- When a GitHub Pull Request is submitted, it is analyzed and merged in `develop` on GitHub, then synced to Azure DevOps that will trigger the CI;
- A Pull Request is then submitted in Azure DevOps to merge `develop` to `master`, it runs the CI again;
- Once merged to `master`, the CI is one last time, but this time it will create a Chocolatey and a NuGet packages that are pushed on private Azure DevOps Artifacts feeds;
- If the CI succeeds and the packages are well pushed, the CD is triggered.

### CI
[![Build Status](https://dev.azure.com/baptistecabrera/Bca/_apis/build/status/Build/Save-MarkdownCommandDocumentation?repoName=bca-savemarkdowncommanddocumentation&branchName=master)](https://dev.azure.com/baptistecabrera/Bca/_build/latest?definitionId=23&repoName=bca-savemarkdowncommanddocumentation&branchName=master)

The CI is an Azure DevOps build pipeline that will:
- Test the script and does code coverage with _[Pester](https://pester.dev/)_;
- Run the _[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)_;
- Mirror the repository to GitHub

### CD
[![Build Status](https://dev.azure.com/baptistecabrera/Bca/_apis/build/status/Release/Save-MarkdownCommandDocumentation?repoName=bca-savemarkdowncommanddocumentation&branchName=master)](https://dev.azure.com/baptistecabrera/Bca/_build/latest?definitionId=24&repoName=bca-savemarkdowncommanddocumentation&branchName=master)

The CD is an Azure DevOps release pipeline is trigerred that will:
- In a **Prerelease** step, install both Chocolatey and Nuget packages from the private feed in a container, and run tests again. If tests are successful, the packages are promoted to `@Prerelease` view inside the private feed;
- In a **Release** step, publish the packages to _[NuGet](https://www.nuget.org/)_ and _[Chocolatey](https://chocolatey.org/)_, and publish the module to _[PowerShell Gallery](https://www.powershellgallery.com/)_, then promote the packages to to `@Release` view inside the private feed.

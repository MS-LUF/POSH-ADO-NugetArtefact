![image](https://www.lucas-cueff.com/files/gallery.png)

# POSH-ADO-NugetArtefact
Standalone PowerShell module managing Nuget packages from an Azure DevOPS or Azure DevOPS Server (ADO) artifact manager

(c) 2025 #lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).

## description
Standalone PowerShell module managing Nuget packages from an Azure DevOPS or Azure DevOPS Server (ADO) artifact manager
This module does not require the usage / installation of nuget.exe, all nuget API endpoints have been managed directly instead.
Main features available :
- Register your ADO Nuget Feed Artifact info locally (ProjectName, API Key...)
- Find a package available and its info in your ADO Nuget Feed Artifact
- Download a NuGet Package from your your ADO Nuget Feed Artifact and extract it locally
- Remove an existing NuGet Package from your your ADO Nuget Feed Artifact

## Changelog
### version (0.5.6) - last public version :
- add SourceName parameter alias (Remove-ADONugetRepositoryPackage, Publish-ADONugetRepositoryPackage, Get-ADONugetRepositoryPackage)
- switch SourceName parameter to optional - not mandatory (Update-ADONugetRepository)
- add action alias 'download' for 'install' (Get-ADONugetRepositoryPackage)
### version (0.5.5) :
- improve regex on several cmdlet to allow dash usage (Set-ADONugetRepository, New-ADONugetRepository)
- add management of env variable *VSS_NUGET_ACCESSTOKEN* to auto detect Nuget API key available on Azure Devops Server Agent when available (Set-ADONugetRepository, New-ADONugetRepository)
### version (0.5.0) - first public version :
- first beta public version

## install from PowerShell Gallery repository
You can easily install it from powershell gallery repository
https://www.powershellgallery.com/packages/POSH-ADO-NugetArtefact/
using a simple powershell command and an internet access :-) 
```
	Install-Module -Name POSH-ADO-NugetArtefact
```
## module content
### public function (available as PowerShell cmdlet)
- Clear-ADONugetRepository
- Export-ADONugetRepository
- Get-ADONugetRepository
- Get-ADONugetRepositoryPackage
- Import-ADONugetRepository
- New-ADONugetRepository
- Publish-ADONugetRepositoryPackage
- Remove-ADONugetRepository
- Remove-ADONugetRepositoryPackage
- Set-ADONugetRepository
- Update-ADONugetRepository
### private function
- Convert-ADONugetRepositoryPackage
- Enable-SkipCertificateChainControlPolicy
- Get-ASTfromFile
- Get-PSFunctionFromAST
- Get-ScriptDirectory
- Invoke-ADOAPI
- Resolve-ADONugetID
- Test-ADONugetRepository

## help and how to
- directly available from powershell using `Get-Help`

## working platform
- working on both Linux/Unix/Mac and WinNt systems
- working on Windows PowerShell and PowerShell (core)
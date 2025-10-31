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
### version (0.5.5) - last public version :
- improve regex on several cmdlet to allow dash usage (Set-ADONugetRepository, New-ADONugetRepository)
- add management of env variable *VSS_NUGET_ACCESSTOKEN* to auto detect Nuget API key available on Azure Devops Server Agent when available (Set-ADONugetRepository, New-ADONugetRepository)
### version (0.5.0) - first public version :
- first beta public version
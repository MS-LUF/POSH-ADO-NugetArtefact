<#
	.SYNOPSIS 
    Standalone PowerShell module managing Nuget packages from an Azure DevOPS or Azure DevOPS Server (ADO) artifact manager

	.DESCRIPTION
    Standalone PowerShell module managing Nuget packages from an Azure DevOPS or Azure DevOPS Server (ADO) artifact manager
    This module does not require the usage / installation of nuget.exe, all nuget API endpoints have been managed directly instead.
    Main features available :
    - Register your ADO Nuget Feed Artifact info locally (ProjectName, API Key...)
    - Find a package available and its info in your ADO Nuget Feed Artifact
    - Download a NuGet Package from your your ADO Nuget Feed Artifact and extract it locally
    - Remove an existing NuGet Package from your your ADO Nuget Feed Artifact
    
    .EXAMPLE
    Set / Declare a new Nuget Feed managed through ADO Artifact
    PS C:\> New-ADONugetRepository -SourceName MySource -APIKey "123456789azerty" -ProjectName "MyProject" -OrganizationName "MyOrganization" -FeedName "MyFeed" -ServerName "MyADOci.tld" -APIKeyName "MyUserAccountORAPIKeyName"

    .EXAMPLE
    List all packages available from your source
    PS C:\> Get-ADORepositoryPackage -Action list -PackageSource MySource

    .EXAMPLE
    Get information for a package in a specific version
    PS C:\> Get-ADORepositoryPackage -Action info -PackageName MyPackage -PackageVersion 1.0.0

    .EXAMPLE
    Install a package from your source
    PS C:\> Get-ADORepositoryPackage -Action install -PackageName MyPackage -OutputDirectory $env:USERPROFILE\desktop
    
#>

$functionFolders = @('Functions')
# Importing all the Functions required for the module from the subfolders.
ForEach ($folder in $functionFolders) {
    $folderPath = Join-Path -Path $PSScriptRoot -ChildPath $folder
    If (Test-Path -Path $folderPath)
    {
        Write-Verbose -Message "Importing from $folder"
        $functions = Get-ChildItem -Path $folderPath -Recurse -Filter '*.ps1'
        ForEach ($function in $functions)
        {
            try {
                Write-Verbose -Message "  Loading $($function.FullName)"
                . ($function.FullName)
            } catch {
                write-error "not able to load / dot source ps1 file $($function.FullName)"
            }
        }
    } else {
         Write-Warning "Path $folderPath not found. Some parts of the module will not work."
    }
}

# Export module public functions
$PublicFunctionNames = @()
$exportedfunctions = $functions | Where-Object {$_.Fullname -notlike "*\Internal\*"}
foreach ($exportedfunction in $exportedfunctions) {
    $ASTFile = Get-ASTfromFile -filepath $exportedfunction.FullName
    $PublicFunctionNames += Get-PSFunctionFromAST -AST $ASTFile
}
Export-ModuleMember -Function $PublicFunctionNames
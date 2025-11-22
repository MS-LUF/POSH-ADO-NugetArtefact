Function Publish-ADONugetRepositoryPackage {
<#
	.SYNOPSIS 
	Publish a new NuGet Package to a ADO Artifact Manager

	.DESCRIPTION
	Publish a new NuGet Package to a ADO Artifact Manager
	
    .PARAMETER PackageFile
	-PackageFile [string]
    full file path of the NuGet package to publish
    File format : .nupkg
    
    .PARAMETER PackageSource
    -PackageSource [string]
    Name of your repository
    
	.OUTPUTS
   	TypeName : System.Collections.Hashtable
		
	.EXAMPLE
    Publish-ADONugetRepositoryPackage -PackageFile C:\MyPackage\MyPackage.1.0.0.nupkg
    Publish Nuget Package C:\MyPackage\MyPackage.1.0.0.nupkg to the default ADO Artifact Manager
#>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
            [string]$PackageFile,
        [parameter(Mandatory=$false,Position=2)]
        [ValidateNotNullOrEmpty()]
        [Alias("SourceName")]
            [string]$PackageSource
    )
    process {
        Test-ADONugetRepository | out-null
        if (!($PackageSource) -and ($global:ADONugetConfig.count -gt 1)) {
            throw "Please provide a valid Package Source using PackageSource Parameter"
        } elseif (!($PackageSource) -and ($global:ADONugetConfig.count -eq 1)) {
            $PackageSource = $global:ADONugetConfig.repositoryname
        }
        Invoke-ADOAPI -SourceName $PackageSource -NugetAPI publish -PackageFilePath $PackageFile
    }
}
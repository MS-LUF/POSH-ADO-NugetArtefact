Function Remove-ADONugetRepositoryPackage {
<#
	.SYNOPSIS 
	Remove a new NuGet Package from a ADO Artifact Manager

	.DESCRIPTION
	Remove a new NuGet Package from a ADO Artifact Manager
	    
    .PARAMETER PackageName
	-PackageName [string]
    name of the package
    
    .PARAMETER PackageSource
    -PackageSource [string]
    Name of your repository

    .PARAMETER PackageVersion
    -PackageVersion [switch]
    version of the package
    
	.OUTPUTS
   	TypeName : None
		
	.EXAMPLE
    Remove-ADONugetRepositoryPackage -PackageName MyPackage -PackageVersion 1.0.0
    Remove NuGet package MyPackage in version 1.0.0 from the default ADO Artifact Manager
#>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
            [string]$PackageName,
        [parameter(Mandatory=$true,Position=2)]
        [ValidateNotNullOrEmpty()]
            [string]$PackageVersion,
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
        $PackageFound = get-adoNugetRepositoryPackage -Action search -PackageSearchQuery $PackageName
        if ($PackageFound.versions.version -contains $PackageVersion) {
            Invoke-ADOAPI -SourceName $PackageSource -NugetAPI delete -PackageID $PackageName -PackageVersion $PackageVersion
        } else {
            write-warning "No package found with Name $($PackageName) and Version $($PackageVersion)"
        }
    }
}
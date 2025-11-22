Function Get-ADONugetRepositoryPackage {
<#
	.SYNOPSIS 
	Request package information, list packages available, download / install package from an ADO Artifact Manager

	.DESCRIPTION
	Request package information, list packages available, download / install package from an ADO Artifact Manager
	
	.PARAMETER Action
    -Action [string]
    Validate Set : "install", "search"
    install : download / install locally a package in a specific version (last version by default)
    search : search a package based on keywords
    
    .PARAMETER PackageName
	-PackageName [string]
    name of the package
    To be used with Action parameter "info" and "install"
    
    .PARAMETER PackageSource
    -PackageSource [string]
    Name of your repository

    .PARAMETER PackageVersion
    -PackageVersion [switch]
    version of the package
    To be used with Action parameter "info" and "install"

    .PARAMETER OutputDirectory
    -OutputDirectory [string]
    install folder where package will be downloaded and extracted. If not set, current folder will be used
    To be used with Action parameter "install"

    .PARAMETER PackageSearchQuery
    -PackageSearchQuery [string]
    Nuget search query to find a package based on NuGet criteria.
    To be used with Action paramter "search"
    Nuget Search Query info : https://docs.microsoft.com/en-us/nuget/consume-packages/finding-and-choosing-packages#search-syntax
    
	.OUTPUTS
   	TypeName : System.Collections.Hashtable
    
    .EXAMPLE
    Get-ADORepositoryPackage -Action install -PackageName myPackage -PackageVersion 1.0.0 -OutputDirectory c:\PackageInstall
    Install a package in a specific version

    .EXAMPLE
    Get-ADORepositoryPackage -Action search -PackageSearchQuery Sysmon
    Search for a package with a name like sysmon
#>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true,Position=0)]
        [ValidateSet("download","install","search")]
            [string]$Action,
        [parameter(Mandatory=$false,Position=1)]
        [ValidateNotNullOrEmpty()]
            [string]$PackageName,
        [parameter(Mandatory=$false,Position=3)]
        [ValidateNotNullOrEmpty()]
        [Alias("SourceName")]
            [string]$PackageSource,
        [parameter(Mandatory=$false,Position=2)]
        [ValidateNotNullOrEmpty()]
            [string]$PackageVersion,
        [parameter(Mandatory=$false,Position=4)]
        [ValidateNotNullOrEmpty()]
            [string]$OutputDirectory,
        [parameter(Mandatory=$false,Position=5)]
        [ValidateNotNullOrEmpty()]
            [string]$PackageSearchQuery
    )
    process {
        Test-ADONugetRepository | out-null
        if (!($PackageSource) -and ($global:ADONugetConfig.count -gt 1)) {
            throw "Please provide a valid Package Source using PackageSource Parameter"
        } elseif (!($PackageSource) -and ($global:ADONugetConfig.count -eq 1)) {
            $PackageSource = $global:ADONugetConfig.repositoryname
        }
        if (!($PackageVersion) -and $PackageName) {
            $AllPackageversion = Invoke-ADOAPI -SourceName $PackageSource -PackageAPI list | where-object {$_.name -eq $PackageName}
            $temppackageversion = $AllPackageversion[0].version
            $PackageVersion = (Invoke-ADOAPI -SourceName $PackageSource -NugetAPI metadata -PackageName $PackageName -PackageVersion $temppackageversion).items.upper
            if (!($PackageVersion)) {
                throw "Not able to find your Package version. Please Provide a valid Package Name and Version using PackageName and PackageVersion parameters"
            }
        }
        switch ($Action) {
            "install" {
                if (!($OutputDirectory)) {
                    $OutputDirectory = Get-ScriptDirectory
                }
                Invoke-ADOAPI -SourceName $PackageSource -NugetAPI download -PackageName $PackageName -PackageVersion $PackageVersion -OutputDirectory $OutputDirectory
            }
            "download" {
                if (!($OutputDirectory)) {
                    $OutputDirectory = Get-ScriptDirectory
                }
                Invoke-ADOAPI -SourceName $PackageSource -NugetAPI download -PackageName $PackageName -PackageVersion $PackageVersion -OutputDirectory $OutputDirectory
            }
            "search" {
                if (!($PackageSearchQuery)) {
                    throw "Please use PackageSearchQuery parameter when using Search option of Action parameter"
                }
                $result = Invoke-ADOAPI -SourceName $PackageSource -NugetAPI query -PackageSearch $PackageSearchQuery
                if ($result.data) {
                    $result.data
                }
            }
        }
    }
}
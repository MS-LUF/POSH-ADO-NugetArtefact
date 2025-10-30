Function Get-ADONugetRepository {
<#
	.SYNOPSIS 
	Get info from an existing ADO Artificat Nuget Source / Repository.

	.DESCRIPTION
	Get info from an existing ADO Artificat Nuget Source / Repository.
	
	.PARAMETER SourceName
	-SourceName [string]
    SourceName of your project 
        
	.OUTPUTS
   	TypeName : System.Collections.Hashtable
		
	.EXAMPLE
    Get-ADONugetRepository -SourceName MySource
    Get repository info for MySource
    
    .EXAMPLE
    Get-ADONugetRepository
    Get all repositories info
#>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$SourceName
    )
    process {
        if (!($global:ADONugetConfig)) {
            throw "please import or create a new source repository using Import-ADONugetRepository or New-ADONugetRepository cmdlets"
        }
        if ($SourceName) {
            if ($global:ADONugetConfig.RepositoryName -contains $SourceName) {
                return $global:ADONugetConfig | Where-Object {$_.RepositoryName -eq $SourceName}
            } else {
                throw "nuget repository $($SourceName) is not defined, please use New-ADONugetRepository"
            }
        } else {
            return $global:ADONugetConfig
        }
    }
}
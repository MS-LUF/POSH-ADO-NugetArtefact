Function Update-ADONugetRepository {
<#
	.SYNOPSIS 
	Update an existing ADO Artificat Nuget Source / Repository with online IDs

	.DESCRIPTION
	Edit an existing ADO Artificat Nuget Source / Repository with online IDs
    IDs are used by nuget endpoint instead of name.
    IDs must be resolved from the name using the primary nuget endpoint.
	
	.PARAMETER SourceName
	-SourceName [string]
    SourceName of your project
    
	.OUTPUTS
   	TypeName : System.Collections.Hashtable
		
	.EXAMPLE
    Update-ADONugetRepository -SourceName MySource
    Update repository MySource with online IDs found on the server
    
#>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullorempty()]
            [string]$SourceName
    )
    process {
        if (!($global:ADONugetConfig)) {
            throw "please import or create a new source repository using Import-ADONugetRepository or New-ADONugetRepository cmdlets"
        }
        $tempids = Resolve-ADONugetID -SourceName $SourceName
        if ($global:ADONugetConfig.RepositoryName -contains $SourceName) {
            $tmpRepository = $global:ADONugetConfig | Where-Object {$_.RepositoryName -eq $SourceName}
            $tmpRepository.FeedID = $tempids.FeedID
            $tmpRepository.ProjectID = $tempids.ProjectID
        } else {
            throw "nuget repository $($SourceName) is not defined, please use New-ADONugetRepository"
        }
        return $global:ADONugetConfig
    }
}
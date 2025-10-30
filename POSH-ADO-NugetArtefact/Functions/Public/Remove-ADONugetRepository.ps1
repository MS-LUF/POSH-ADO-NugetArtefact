Function Remove-ADONugetRepository {
<#
	.SYNOPSIS 
	Remove an existing ADO Artificat Nuget Source / Repository.

	.DESCRIPTION
	Remove an existing ADO Artificat Nuget Source / Repository.
	
	.PARAMETER SourceName
	-SourceName [string]
    SourceName of your project 
        
	.OUTPUTS
   	TypeName : System.Collections.Hashtable
		
	.EXAMPLE
    Remove-ADONugetRepository -SourceName MySource
    remove repository for MySource
    
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
        $script:tmpADONugetConfig = {$global:ADONugetConfig}.Invoke()
        if ($script:tmpADONugetConfig.RepositoryName -contains $SourceName) {
            for ($i=0;$i -le $script:tmpADONugetConfig.count;$i++) {
                if ($script:tmpADONugetConfig[$i].RepositoryName -eq $SourceName) {
                    $script:tmpADONugetConfig.remove($script:tmpADONugetConfig[$i])
                    break
                }
            }
        } else {
            throw "nuget repository $($SourceName) is not defined, please use New-ADONugetRepository"
        }
        $global:ADONugetConfig = $script:tmpADONugetConfig
        return $global:ADONugetConfig
    }
}
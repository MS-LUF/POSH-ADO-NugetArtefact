Function Clear-ADONugetRepository {
<#
	.SYNOPSIS 
	Clear all ADO Artificat Nuget Sources / Repositories set

	.DESCRIPTION
	Clear all ADO Artificat Nuget Sources / Repositories set
	    
	.OUTPUTS
   	None
		
	.EXAMPLE
    Clear-ADONugetRepository
    Remove all all ADO Artificat Nuget Sources / Repositories set locally
#>
    [cmdletbinding()]
    param()
    process {
        if (!($global:ADONugetConfig)) {
            throw "please import or create a new source repository using Import-ADONugetRepository or New-ADONugetRepository cmdlets"
        } else {
            Remove-Variable ADONugetConfig -Force -Scope Global
        }
    }
}
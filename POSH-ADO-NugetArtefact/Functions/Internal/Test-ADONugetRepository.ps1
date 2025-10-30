Function Test-ADONugetRepository {
<#
	.SYNOPSIS 
	Test if your ADO Package Registry Source / Repository is correctly set locally

	.DESCRIPTION
	Test if your ADO Package Registry Source / Repository is correctly set locally
	    
	.OUTPUTS
   	TypeName : System.Collections.Hashtable
		
	.EXAMPLE
	test your repository source configuration
    C:\PS> Test-ADONugetRepository
    
#>
    [cmdletbinding()]
    param()
    process {
        if (!($global:ADONugetConfig)) {
            throw "No ADO Nuget Config loaded, please use Import-ADONugetRepository or New-ADONugetRepository first"
        } else {
            return $global:ADONugetConfig
        }
    }
}
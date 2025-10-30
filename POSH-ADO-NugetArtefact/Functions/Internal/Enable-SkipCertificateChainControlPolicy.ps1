Function Enable-SkipCertificateChainControlPolicy {
<#
	.SYNOPSIS 
	Allow self sign certificate or untrusted certificate chain in HTTPS communication

	.DESCRIPTION
	Allow self sign certificate or untrusted certificate chain in HTTPS communication
	    
	.OUTPUTS
   	None
		
	.EXAMPLE
	Enable bypass certificate chain control for HTTPS
    C:\PS> Enable-SkipCertificateChainControlPolicy -verbose
    
#>
    [cmdletbinding()]
    param()
    process {
        if ($PSVersionTable.PSVersion.major -eq 5) {
            write-verbose -message "Windows PowerShell found - create custom class to allow self signed certificate"
            try {
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
            } catch {
                throw "not able to create TrustAllCertsPolicy custom .NET Class"
            }
            try {
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            } catch {
                throw "not able to call CertificatePolicy and set TrustAllCertsPolicy"
            }
        } else {
            write-verbose -message "PowerShell core found - set default parameter SkipCertificateCheck for invoke-restmethod and invoke-webrequest to allow self signed certificate"
            $Script:PSDefaultParameterValues = @{
                "invoke-restmethod:SkipCertificateCheck" = $true
                "invoke-webrequest:SkipCertificateCheck" = $true
            }
        }
    }
}
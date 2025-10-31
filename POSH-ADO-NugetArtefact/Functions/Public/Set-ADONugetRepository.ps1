Function Set-ADONugetRepository {
<#
	.SYNOPSIS 
	Edit an existing ADO Artificat Nuget Source / Repository

	.DESCRIPTION
	Edit an existing ADO Artificat Nuget Source / Repository.
	
	.PARAMETER SourceName
	-SourceName [string]
    SourceName of your project

    .PARAMETER ServerName
	-ServerName [string]
    ADO Server or service FQDN
    
    .PARAMETER APIKey
	-APIKey [string]
    ADO API Key / Access Token (mandatory to access ADO project repository and package registry). Require API Access : read_api, read_repository, read_registry
    
    .PARAMETER APIKeyName
	-APIKeyName [string]
	ADO API Key Name / Access Token Name. Require for Basic Auth with several nuget service (publish). if a personal access token is used, this value must be the account name.
    
    .PARAMETER ProjectName
    -ProjectName [string]
    ProjectName of your ADO project

    .PARAMETER FeedName
    -ProjectName [string]
    ProjectName of your ADO Nuget feed in ADO

    .PARAMETER OrganizationName
    -OrganizationName [string]
    OrganizationName of your OrganizationName project

    .PARAMETER AllowInsecureConnections
    -AllowInsecureConnections [switch]
    Not recommanded : Allow connection to an unsecure HTTS feed (self signed certificate on web endpoint or certificate chain not trusted locally)
    
	.OUTPUTS
   	TypeName : System.Collections.Hashtable
		
	.EXAMPLE
    Set-ADONugetRepository -SourceName MySource -APIKey "123456789azerty" -ProjectName "12345" -FeedName "MyFeed" -ServerName "MyADOci.tld" -APIKeyName "MyUserAccountORAPIKeyName"
    Update repository MySource
    
#>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullorempty()]
            [string]$SourceName,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$ServerName,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$APIKey,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$APIKeyName,
        [parameter(Mandatory=$true)]
        [ValidatePattern("^\d*$")]
            [string]$ProjectName,
        [parameter(Mandatory=$true)]
        [ValidatePattern("^[a-zA-Z0-9-]+$")]
            [string]$OrganizationName,
        [parameter(Mandatory=$true)]
        [ValidatePattern("^[a-zA-Z0-9-]+$")]
            [string]$FeedName,
        [parameter(mandatory=$false)]
            [switch]$AllowInsecureConnections
    )
    process {
        if (!($global:ADONugetConfig)) {
            throw "please import or create a new source repository using Import-ADONugetRepository or New-ADONugetRepository cmdlets"
        }
        if (!($APIKey)) {
            if (test-path env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS) {
                write-verbose -message "Azure DevOps server VSS_NUGET_EXTERNAL_FEED_ENDPOINTS env variable found, autodiscovering PAT"
                $objVSS_NUGET_EXTERNAL_FEED_ENDPOINTS = $env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS | convertfrom-json
                if ($objVSS_NUGET_EXTERNAL_FEED_ENDPOINTS.endpointCredentials.password) {
                    $APIKey = $objVSS_NUGET_EXTERNAL_FEED_ENDPOINTS.endpointCredentials.password
                } else {
                    throw "invalid VSS_NUGET_EXTERNAL_FEED_ENDPOINTS env variable, password property is missing in the json content"
                }
            } elseif (test-path env:VSS_NUGET_ACCESSTOKEN) {
                write-verbose -message "Azure DevOps server VSS_NUGET_ACCESSTOKEN env variable found, autodiscovering PAT"
                $APIKey = $env:VSS_NUGET_ACCESSTOKEN
            } else {
                throw "Please set APIKey parameter, VSS_NUGET_EXTERNAL_FEED_ENDPOINTS and VSS_NUGET_ACCESSTOKEN env variable not found"
            }   
        }
        if (!($APIKeyName)) {
            $APIKeyName = $FeedName
        }
        if ($global:ADONugetConfig.RepositoryName -contains $SourceName) {
            $tmpRepository = $global:ADONugetConfig | Where-Object {$_.RepositoryName -eq $SourceName}
            $tmpRepository.ProjectName = $ProjectName
            $tmpRepository.OrganizationName = $OrganizationName
            $tmpRepository.FeedName = $FeedName
            $tmpRepository.APIKey = $APIKey
            $tmpRepository.APIKeyName = $APIKeyName
            $tmpRepository.FeedID = ""
            $tmpRepository.ProjectID = ""
            if ($AllowInsecureConnections) {
                $tmpRepository.AllowInsecureConnections = $true
            }
        } else {
            throw "nuget repository $($SourceName) is not defined, please use New-ADONugetRepository"
        }
        return $global:ADONugetConfig
    }
}
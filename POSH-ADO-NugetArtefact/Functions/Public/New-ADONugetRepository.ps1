Function New-ADONugetRepository {
<#
	.SYNOPSIS 
	Create a new ADO Artificat Nuget Source / Repository

	.DESCRIPTION
	Create or add a new ADO Artificat Nuget Source / Repository. This is a prerequisite to use the other cmdlets like Get-ADONugetRepositoryPackage
	
	.PARAMETER SourceName
	-SourceName [string]
    SourceName of your project 

    .PARAMETER ServerName
	-ServerName [string]
    ADO Server FQDN, if dev.azure.com is used, use 'dev.azure.com' value.
    
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
    New-ADONugetRepository -SourceName MySource -APIKey "123456789azerty" -ProjectName "MyProject" -OrganizationName "MyOrganization" -FeedName "MyFeed" -ServerName "MyADOci.tld" -APIKeyName "MyUserAccountORAPIKeyName"
    Register new repository MySource
    
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
        [ValidatePattern("^\w*$")]
            [string]$ProjectName,
        [parameter(Mandatory=$true)]
        [ValidatePattern("^\w*$")]
            [string]$OrganizationName,
        [parameter(Mandatory=$true)]
        [ValidatePattern("^\w*$")]
            [string]$FeedName,
        [parameter(mandatory=$false)]
            [switch]$AllowInsecureConnections
    )
    process {
        if (!($APIKey)) {
            if (test-path env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS) {
                write-verbose -message "Azure DevOps server VSS_NUGET_EXTERNAL_FEED_ENDPOINTS env variable found, autodiscovering PAT"
                $objVSS_NUGET_EXTERNAL_FEED_ENDPOINTS = $env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS | convertfrom-json
                if ($objVSS_NUGET_EXTERNAL_FEED_ENDPOINTS.endpointCredentials.password) {
                    $APIKey = $objVSS_NUGET_EXTERNAL_FEED_ENDPOINTS.endpointCredentials.password
                } else {
                    throw "invalid VSS_NUGET_EXTERNAL_FEED_ENDPOINTS env variable, password property is missing in the json content"
                }
            } else {
                throw "Please set APIKey parameter, VSS_NUGET_EXTERNAL_FEED_ENDPOINTS env variable not found"
            }    
        }
        if (!($ServerName)) {
            $ServerName = "pkgs.dev.azure.com"
        }
       if (!($APIKeyName)) {
            $APIKeyName = $FeedName
       }
       if ($AllowInsecureConnections) {
            $AllowInsecureConnectionsStatus = $true
       } else {
            $AllowInsecureConnectionsStatus = $false
       }
       if ($global:ADONugetConfig) {
        if ($global:ADONugetConfig.RepositoryName -notcontains $SourceName) {
            $global:ADONugetConfig += @{"APIKey" = $APIKey; "APIKeyName" = $APIKeyName ;"ProjectName" = $ProjectName; "ProjectID" = ""; "FeedName" = $FeedName; "FeedID" = "" ;"OrganizationName" = $OrganizationName; "RepositoryName" = $SourceName; "Server" = $ServerName; "AllowInsecureConnections" = $AllowInsecureConnectionsStatus}
        } else {
            throw "nuget repository $($SourceName) is already defined"
        }
       } else {
        $global:ADONugetConfig = [System.Collections.ArrayList]@(@{"APIKey" = $APIKey; "APIKeyName" = $APIKeyName ;"ProjectName" = $ProjectName; "ProjectID" = ""; "FeedName" = $FeedName; "FeedID" = "" ;"OrganizationName" = $OrganizationName; "RepositoryName" = $SourceName; "Server" = $ServerName; "AllowInsecureConnections" = $AllowInsecureConnectionsStatus})
       }
       return $global:ADONugetConfig
    }
}
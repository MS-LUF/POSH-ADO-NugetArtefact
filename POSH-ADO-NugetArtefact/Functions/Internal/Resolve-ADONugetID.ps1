function Resolve-ADONugetID {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullorempty()]
            [string]$SourceName
    )
    process {
        Test-ADONugetRepository | Out-Null
        $Repository = $global:ADONugetConfig | Where-Object {$_.RepositoryName -eq $SourceName}
        if (!($Repository)) {
            throw "repository not found, please use Import-ADONugetRepository or New-ADONugetRepository first"
        }
        if ($repository.AllowInsecureConnections) {
            Enable-SkipCertificateChainControlPolicy
        }
        $Headers = @{
            "Authorization" = "Basic "+ [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Repository.APIKeyName):$($Repository.APIKey)"))
        }
        $BaseADOURI = "https://$($Repository.server)/$($Repository.OrganizationName)/$($Repository.ProjectName)/_packaging/$($Repository.FeedName)/nuget/v3/index.json"
        $params = @{
            "Headers" = $Headers
            "UserAgent" = "NuGet Command Line/6.14.0 (WINDOWS)"
            "UseBasicParsing" = $true
            "URI" = $BaseADOURI
        }
        try {
            $result = Invoke-WebRequest @params
        } catch {
            write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
            write-verbose -message "Error Message: $($_.Exception.Message)"
            write-verbose -message "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
            write-verbose -message "HTTP error message:$($_.Exception.Response.StatusDescription)"
        }
        if ($result.Content) {
            $jsonresult = $result.content | convertfrom-json
            $adoserviceids = [System.Uri]$jsonresult.'resources'[0].'@id'
            $adoserviceidssplit = $adoserviceids.AbsolutePath.tostring() -split "/"
            return @{"ProjectID" = $adoserviceidssplit[2]; "FeedID" = $adoserviceidssplit[4] }
        } else {
            throw "empty web response received"
            $result
        }
    }
}
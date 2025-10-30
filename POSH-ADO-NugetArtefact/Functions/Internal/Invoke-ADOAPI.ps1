Function Invoke-ADOAPI {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullorempty()]
            [string]$SourceName,
        [parameter(Mandatory=$false)]
        [ValidateSet("download","query", "publish","delete")]
            [string]$NugetAPI,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$PackageName,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$PackageVersion,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$OutputDirectory,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$PackageID,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$PackageSearch,
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$PackageFilePath
    )
    process {
        Test-ADONugetRepository | Out-Null
        $tempFilePath = [System.IO.Path]::GetTempFileName()
        $Repository = $global:ADONugetConfig | Where-Object {$_.RepositoryName -eq $SourceName}
        if (!($Repository)) {
            throw "repository not found, please use Import-ADONugetRepository or New-ADONugetRepository first"
        }
        if ($repository.AllowInsecureConnections) {
            Enable-SkipCertificateChainControlPolicy
        }
        $Headers = @{
            "X-NuGet-ApiKey" = "az"
            "X-NuGet-Client-Version" = "6.14.0"
            "Authorization" = "Basic "+ [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Repository.APIKeyName):$($Repository.APIKey)"))
        }
        $BaseADOURI = "https://$($Repository.server)/$($Repository.OrganizationName)/$($Repository.ProjectID)/_packaging/$($Repository.FeedID)"
        $params = @{
            "Headers" = $Headers
            "UserAgent" = "NuGet Command Line/6.14.0 (WINDOWS)"
            "UseBasicParsing" = $true
        }
        if ($NugetAPI) {
            switch ($NugetAPI) {
                "download" {
                    if (!($PackageName) -and !($PackageVersion) -and !($OutputDirectory)) {
                        throw "please use PackageName, PackageVersion, OutputDirectory parameters when using NugetAPI Download parameters"
                    }
                    if (!(test-path $OutputDirectory)) {
                        throw "please set an existing target folder as OutputDirectory when using NugetAPI Download parameters"
                    }
                    $URI = $BaseADOURI + "/nuget/v3/flat2/$($PackageName)/$($PackageVersion)/$($PackageName).$($PackageVersion).nupkg"
                }
                "query" {
                    if (!($PackageSearch)) {
                        throw "please use PackageSearch parameter when using NugetAPI query parameter"
                    }
                    $URI = $BaseADOURI + "/nuget/v3/query2/?q=$([System.Web.HTTPUtility]::UrlEncode($PackageSearch))&skip=0&take=50&prerelease=true&semVerLevel=2.0.0"
                }
                "publish" {
                    if (!($PackageFilePath)) {
                        throw "please use PackageFilePath parameter when using NugetAPI publish parameter"
                    }
                    $URI = $BaseADOURI + "/nuget/v2/"
                    $convertedinfo = Convert-ADONugetRepositoryPackage -PackageFilePath $PackageFilePath
                    $params.add("Infile",$convertedinfo.Infile)
                    $params.add("ContentType",$convertedinfo.contenttype)
                    $params.add("method","Put")
                    $Headers.add("Accept-Encoding","gzip, deflate")
                }
                "delete" {
                    if (!($PackageID) -or !($PackageVersion)) {
                        throw "please use PackageID and PackageVersion parameters when using NugetAPI delete parameter"
                    }
                    $URI = $BaseADOURI + "/nuget/v2/$($PackageID)/$($PackageVersion)"
                    $params.add("method","delete")
                }
            }
            $params.add("URI",$URI)
            write-verbose -message "HTTP HEADERS : $($Headers | out-string)"
        } 
        if ($OutputDirectory) {
            try {
                $result = Invoke-WebRequest -Uri $URI -Headers $Headers -UserAgent "NuGet Command Line/6.14.0 (WINDOWS)" -OutFile $tempFilePath
            } catch {
                if ($PackageAPI) {
                    write-warning -message "Not able to connect to ADO native Package Registry API $($PackageAPI)"
                } elseif ($NugetAPI) {
                    write-warning -message "Not able to connect to ADO Nuget API $($NugetAPI)"
                }
                write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
                write-verbose -message "Error Message: $($_.Exception.Message)"
                write-verbose -message "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
                write-verbose -message "HTTP error message:$($_.Exception.Response.StatusDescription)"
            }
            if ($tempFilePath) {
                $newdirectory = "$($packagename).$($packageversion)"
                $newoutputdirectory = join-path $OutputDirectory $newdirectory
                if (!(test-path $newoutputdirectory)) {
                    new-item -ItemType Directory -Path $newoutputdirectory -Force | Out-Null
                }
                $ziptempfile = "$((get-item -path $tempFilePath).basename).zip"
                $ziptempfullpath = join-path (get-item $tempFilePath).Directory $ziptempfile
                move-item -path $tempFilePath -Destination $ziptempfullpath -Force | out-null
                expand-archive -Path $ziptempfullpath -DestinationPath $newoutputdirectory -Force | out-null
                Remove-Item -path $ziptempfullpath -Force | Out-Null
                if (test-path (join-path $newoutputdirectory "_rels")) {
                    remove-item -path (join-path $newoutputdirectory "_rels") -force -Recurse | out-null
                }
                if (test-path (join-path $newoutputdirectory "package")) {
                    remove-item -path (join-path $newoutputdirectory "package") -force -Recurse | out-null
                }
                if (test-path (join-path $newoutputdirectory "``[Content_Types``].xml")) {
                    remove-item -path (join-path $newoutputdirectory "``[Content_Types``].xml") -force | out-null
                }
            }
        } else {
            try {
                $result = Invoke-WebRequest @params
                if ($result.content) {
                    write-verbose -message $result.content
                    return ($result.Content | ConvertFrom-Json)
                } else {
                    return $result
                }
            } catch {
                if ($PackageAPI) {
                    write-warning -message "Not able to connect to ADO native Package Registry API $($PackageAPI)"
                } elseif ($NugetAPI) {
                    write-warning -message "Not able to connect to ADO Nuget API $($NugetAPI)"
                }
                write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
                write-verbose -message "Error Message: $($_.Exception.Message)"
                write-verbose -message "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
                write-verbose -message "HTTP error message:$($_.Exception.Response.StatusDescription)"
            }
        }
    }
}
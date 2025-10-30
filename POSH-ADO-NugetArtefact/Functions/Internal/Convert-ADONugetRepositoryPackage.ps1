Function Convert-ADONugetRepositoryPackage {
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullorempty()]
            [string]$PackageFilePath
    )
    process {
        if (!(test-path $PackageFilePath)) {
            throw "please provide a path to an existing nupkg file"
        }
        if ((get-item -Path $PackageFilePath).extension -ne ".nupkg") {
            throw "please provide a valid nupkg file"
        }
        $boundary = [Guid]::NewGuid().ToString()
        $bodyfileheader = @(
            "--$($boundary)",
            "Content-Type: application/octet-stream",
            "Content-Disposition: form-data; name=package; filename=package.nupkg; filename*=utf-8''package.nupkg",
            "`r`n"
        )
        $bodyfilefooter = "`r`n--$($boundary)--"
        $requestInFile = [System.IO.Path]::GetTempFileName()
        try {
            $fileStream = (New-Object -TypeName 'System.IO.FileStream' -ArgumentList ($requestInFile, [IO.FileMode]'Create', [IO.FileAccess]'Write'))
            $bytes = [Text.Encoding]::UTF8.GetBytes(($bodyfileheader -join "`r`n"))
            $fileStream.Write($bytes, 0, $bytes.Length)
            $bytes = [IO.File]::ReadAllBytes($PackageFilePath)
            $fileStream.Write($bytes, 0, $bytes.Length)
            $bytes = [Text.Encoding]::UTF8.GetBytes($bodyfilefooter)
            $fileStream.Write($bytes, 0, $bytes.Length)
        } catch {
            "not able to convert $($PackageFilePath) into a compliant 'multipart/form-data' with boundary $($boundary)"
        }
        $fileStream.Close()
        return @{
            "InFile" = $requestInFile
            "ContentType" = "multipart/form-data; boundary=`"{0}`"" -f $boundary
        }
    }
}
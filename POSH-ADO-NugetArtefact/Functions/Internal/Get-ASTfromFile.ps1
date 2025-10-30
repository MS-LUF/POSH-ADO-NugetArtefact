function Get-ASTfromFile {
    [CmdletBinding()]
    param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullorempty()]
            [string]$filepath
    )
    process {
        if (Test-Path $filepath) {
            [System.Management.Automation.Language.Parser]::ParseFile($filepath, [ref]$null, [ref]$null)
        } else {
            write-error "$($filepath) not found"
        }
    }
}
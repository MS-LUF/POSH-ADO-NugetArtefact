Function Import-ADONugetRepository {
<#
	.SYNOPSIS 
	Import an ADO Artificat Nuget Source / Repository from a configuration file

	.DESCRIPTION
	Import an ADO Artificat Nuget Source / Repository from a configuration file. This is a prerequisite to use the other cmdlets like Get-ADONugetRepositoryPackage
	
    .PARAMETER XMLFolderPath
    -XMLFolderPath [string]
    Folder path where from your XML config file will be imported. If not set, $home\.PoshADO will be used

    .PARAMETER EncryptKeyInLocalFile
    -EncryptKeyInLocalFile [switch]
    encrypt apikey with password provided in MasterPassword parameter

    .PARAMETER MasterPassword
    -MasterPassword [securestring]
    password used to encrypt your API Keys
    
	.OUTPUTS
       TypeName : System.Collections.Hashtable
       
    .EXAMPLE
    Import-ADONugetRepository
	Import your configuration from default folder $home\.PoshADO
		
	.EXAMPLE
    Import-ADONugetRepository -XMLFolderPath c:\MyFolder
    import your configuration from c:\MyFolder

    .EXAMPLE
    Import-ADONugetRepository -XMLFolderPath c:\MyFolder -EncryptKeyInLocalFile -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force)
    import your encrypted configuration from c:\MyFolder
#>
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$false)]
        [ValidateNotNullorempty()]
            [string]$XMLFolderPath,
        [parameter(Mandatory=$false)]
            [switch]$EncryptKeyInLocalFile,
        [parameter(Mandatory=$false)]
            [securestring]$MasterPassword
    )
    process {
        if (!$home) {
			$global:home = $env:userprofile
		}
        if (!($XMLFolderPath)) {
            $XMLFolderPath = join-path $global:home ".PoshADO"
        }
        $XMLFile = join-path $XMLFolderPath "ADORepository.xml"
        if (!(test-path $XMLFile)) {
            throw "config file $($XMLFile) does not exist"
        }
        if ($EncryptKeyInLocalFile.IsPresent) {
            If (!$MasterPassword) {
                throw "Please provide a valid Master Password to protect the API Key storage on disk and a valid API Key"
            } else {
                $script:tmpADONugetConfig = Import-Clixml -Path $XMLFile
                $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword
                for ($i=0;$i -le ($script:tmpADONugetConfig.count -1);$i++) {
                    if ($script:tmpADONugetConfig[$i].apikey -and $script:tmpADONugetConfig[$i].Salt) {
                        try {
                            $Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $script:tmpADONugetConfig[$i].Salt
                            $KeyBytes  = $Rfc2898Deriver.GetBytes(32)
                            $SecString = ConvertTo-SecureString -Key $KeyBytes $script:tmpADONugetConfig[$i].apikey
                            $SecureStringToBSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecString)
                            $APIKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto($SecureStringToBSTR)
                            $script:tmpADONugetConfig[$i].apikey = $APIKey
                            $script:tmpADONugetConfig[$i].remove('Salt')
                        } catch {
                            throw "Not able to set correctly your API Key, your passphrase my be incorrect"
                        }
                    }
                }
                $global:ADONugetConfig = $script:tmpADONugetConfig.clone()
            }
        } else {
            $global:ADONugetConfig = Import-Clixml -Path $XMLFile
        }
        return $global:ADONugetConfig
    }
}
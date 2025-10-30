Function Export-ADONugetRepository {
<#
	.SYNOPSIS 
	export an ADO Artificat Nuget Source / Repository to a configuration file

	.DESCRIPTION
	export an ADO Artificat Nuget Source / Repository to a configuration file
	
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
    Export-ADONugetRepository
	Export your configuration to default folder $home\.PoshADO
    
    .EXAMPLE
    Export-ADONugetRepository -XMLFolderPath c:\MyFolder
    Export your configuration to c:\MyFolder

    .EXAMPLE
    Export-ADONugetRepository -XMLFolderPath c:\MyFolder -EncryptKeyInLocalFile -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force)
    Export and encrypt your configuration to c:\MyFolder
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
        if (!($global:ADONugetConfig)) {
            throw "please import or create a new source repository using Import-ADONugetRepository or New-ADONugetRepository cmdlets"
        }
        if (!$home) {
			$global:home = $env:userprofile
		}
        if (!($XMLFolderPath)) {
            $XMLFolderPath = join-path $global:home ".PoshADO"
            write-verbose $XMLFolderPath
            $XMLFile = join-path $XMLFolderPath "ADORepository.xml"
            if (!(test-path $XMLFolderPath)) {
                New-Item -ItemType Directory -Path $XMLFolderPath -Force | out-null
            }
        } else {
            $XMLFile = join-path $XMLFolderPath "ADORepository.xml"
        }
        if ($EncryptKeyInLocalFile.IsPresent) {
            If (!$MasterPassword) {
                throw "Please provide a valid Master Password to protect the API Key storage on disk and a valid API Key"
            } else {
                $script:tmpADONugetConfig = $global:ADONugetConfig.clone()
                for ($i=0;$i -le ($script:tmpADONugetConfig.count -1);$i++) {
                    if ($script:tmpADONugetConfig[$i].apikey) {
                        [Security.SecureString]$SecureKeyString = ConvertTo-SecureString -String $script:tmpADONugetConfig[$i].apikey -AsPlainText -Force
                        $SaltBytes = New-Object byte[] 32
                        $RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
                        $RNG.GetBytes($SaltBytes)
                        $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword
                        $Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes
                        $KeyBytes  = $Rfc2898Deriver.GetBytes(32)
                        $EncryptedString = $SecureKeyString | ConvertFrom-SecureString -key $KeyBytes
                        $script:tmpADONugetConfig[$i].add('Salt',$SaltBytes)
                        $script:tmpADONugetConfig[$i].APIKey = $EncryptedString
                    }
                }
                try {
                    Export-Clixml -InputObject $tmpADONugetConfig -Path $XMLFile -Force
                    Clear-ADONugetRepository
                    Import-ADONugetRepository @PSBoundParameters
                } catch {
                    throw "invalid file XML file path"
                }
            }
        } else {
            try {
                Export-Clixml -InputObject $global:ADONugetConfig -Path $XMLFile -Force
                return $global:ADONugetConfig
            } catch {
                throw "invalid file XML file path"
            }
        }
    }
}
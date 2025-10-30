Function Get-ScriptDirectory {
	[cmdletbinding()]
	Param ()
	if ($psISE) {
        $ScriptPath = Split-Path -Parent $psISE.CurrentFile.FullPath
    } elseif($PSVersionTable.PSVersion.Major -gt 3) {
        $ScriptPath = $PSScriptRoot
    } else {
        $ScriptPath = split-path -parent $MyInvocation.MyCommand.Path
    }
	$ScriptPath
}
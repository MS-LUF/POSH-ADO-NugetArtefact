function Get-PSFunctionFromAST {
    [CmdletBinding()]
    [parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
    [ValidateNotNullorempty()]
    param (
        [System.Management.Automation.Language.ScriptBlockAst]$AST
    )
    process {
        $ASTFunctions = $AST.FindAll( {
            param([System.Management.Automation.Language.Ast] $AST)

            $AST -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
            # Class methods have a FunctionDefinitionAst under them as well, but we don't want them.
            ($PSVersionTable.PSVersion.Major -lt 5 -or
                $AST.Parent -isnot [System.Management.Automation.Language.FunctionMemberAst])
        }, $true)
    $ASTFunctions.Name
    }
}
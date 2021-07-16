BeforeDiscovery {
    $commandName = Split-Path ($PSCommandPath.Replace('.Tests.ps1','')) -Leaf
    $commandName = $commandName.Replace('-','-Tss')
}
Describe "$commandName verify parameters" {
    BeforeDiscovery {
        [object[]]$knownParameters = 'TssSession','Permission','Scope',
        # Folder param set
        'FolderId','IncludeSubFolders',
        # field param set
        'Field','FieldText','ExactMatch','FieldSlug','ExtendedField','ExtendedTypeId',
        # secret param set
        'Id','SecretTemplateId','SiteId','HeartbeatStatus','IncludeInactive','ExcludeActive','RpcEnabled','SharedWithMe','PasswordTypeIds','ExcludeDoubleLock','DoubleLockId'
        [object[]]$currentParams = ([Management.Automation.CommandMetaData]$ExecutionContext.SessionState.InvokeCommand.GetCommand($commandName,'Function')).Parameters.Keys
        [object[]]$commandDetails = [System.Management.Automation.CommandInfo]$ExecutionContext.SessionState.InvokeCommand.GetCommand($commandName,'Function')
        $unknownParameters = Compare-Object -ReferenceObject $knownParameters -DifferenceObject $currentParams -PassThru
    }
    Context "Verify parameters" -Foreach @{currentParams = $currentParams} {
        It "$commandName should contain <_> parameter" -TestCases $knownParameters {
            $_ -in $currentParams | Should -Be $true
        }
        It "$commandName should not contain parameter: <_>" -TestCases $unknownParameters {
            $_ | Should -BeNullOrEmpty
        }
    }
    Context "Command specific details" {
        It "$commandName should set OutputType to TssSecretLookup" -TestCases $commandDetails {
            $_.OutputType.Name | Should -Be 'TssSecretLookup'
        }
    }
}
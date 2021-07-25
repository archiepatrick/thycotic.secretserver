BeforeDiscovery {
    $commandName = Split-Path ($PSCommandPath.Replace('.Tests.ps1','')) -Leaf
    $commandName = $commandName.Replace('-','-Tss')
}
Describe "$commandName verify parameters" {
    BeforeDiscovery {
        [object[]]$knownParameters = 'TssSession', 'Id',
        <# Restricted params #>
        'Comment', 'ForceCheckIn', 'TicketNumber', 'TicketSystemId',

        <# CheckIn #>
        'CheckIn',

        <# General settings #>
        'Active', 'EnableInheritSecretPolicy', 'FolderId', 'GenerateSshKeys', 'HeartbeatEnabled', 'SecretPolicy', 'SiteId','IsOutOfSync', 'SecretName',

        <# Other params for PUT /secrets/{id} endpoint #>
        'AutoChangeEnabled', 'AutoChangeNextPassword', 'EnableInheritPermission'

        [object[]]$currentParams = ([Management.Automation.CommandMetaData]$ExecutionContext.SessionState.InvokeCommand.GetCommand($commandName, 'Function')).Parameters.Keys
        [object[]]$commandDetails = [System.Management.Automation.CommandInfo]$ExecutionContext.SessionState.InvokeCommand.GetCommand($commandName,'Function')
        $unknownParameters = Compare-Object -ReferenceObject $knownParameters -DifferenceObject $currentParams -PassThru
    }
    Context "Verify parameters" -Foreach @{currentParams = $currentParams } {
        It "$commandName should contain <_> parameter" -TestCases $knownParameters {
            $_ -in $currentParams | Should -Be $true
        }
        It "$commandName should not contain parameter: <_>" -TestCases $unknownParameters {
            $_ | Should -BeNullOrEmpty
        }
    }
}
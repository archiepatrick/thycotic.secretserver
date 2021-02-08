﻿BeforeDiscovery {
    $commandName = Split-Path ($PSCommandPath.Replace('.Tests.ps1','')) -Leaf
    . ([IO.Path]::Combine([string]$PSScriptRoot, '..', 'constants.ps1'))
}
Describe "$commandName verify parameters" {
    BeforeDiscovery {
        [object[]]$knownParameters = 'TssSession', 'Id'
        [object[]]$currentParams = ([Management.Automation.CommandMetaData]$ExecutionContext.SessionState.InvokeCommand.GetCommand($commandName,'Function')).Parameters.Keys
        [object[]]$commandDetails = [System.Management.Automation.CommandInfo]$ExecutionContext.SessionState.InvokeCommand.GetCommand($commandName,'Function')
        $unknownParameters = Compare-Object -ReferenceObject $knownParameters -DifferenceObject $currentParams -PassThru
    }
    Context "Verify parmaeters" -Foreach @{currentParams = $currentParams} {
        It "$commandName should contain <_> parameter" -TestCases $knownParameters {
            $_ -in $currentParams | Should -Be $true
        }
        It "$commandName should not contain parameter: <_>" -TestCases $unknownParameters {
            $_ | Should -BeNullOrEmpty
        }
    }
    Context "Command specific details" {
        It "$commandName should set OutputType to TssDelete" -TestCases $commandDetails {
            $_.OutputType.Name | Should -Be 'TssDelete'
        }
    }
}
Describe "$commandName works" {
    BeforeDiscovery {
        $session = New-TssSession -SecretServer $ss -Credential $ssCred
        $invokeParams = @{
            Uri = "$ss/api/v1/folders?take=$($session.take)"
            ExpandProperty = 'records'
            PersonalAccessToken = $session.AccessToken
        }
        $getFolders = Invoke-TssRestApi @invokeParams
        $tssSecretFolder = $getFolders.Where({$_.FolderPath -eq '\tss_module_testing\DeleteFolder'})

        $folderName = "tssDeleteTest$(Get-Random)"
        $createdFolder = Get-TssFolderStub -TssSession $session | New-TssFolder -TssSession $session -FolderName $folderName -ParentFolderId $tssSecretFolder.Id
        $deletedFolder = Remove-TssFolder -TssSession $session -Id $createdFolder.Id

        $session.SessionExpire()
        $props = 'Id', 'ObjectType'
    }
    Context "Checking" -Foreach @{createdFolder = $createdFolder; deletedFolder = $deletedFolder} {
        It "Should not be empty" {
            $createdFolder | Should -Not -BeNullOrEmpty
            $deletedFolder | Should -Not -BeNullOrEmpty
        }
        It "Should output <_> property" -TestCases $props {
            $deletedFolder.PSObject.Properties.Name | Should -Contain $_
        }
        It "Should have FolderId of <_.Id>" -TestCases $createdFolder {
            $deletedFolder.Id | Should -Be $_.Id
        }
    }
}
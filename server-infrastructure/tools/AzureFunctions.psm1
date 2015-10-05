function Set-AzureAPICredentials {
    Param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Password
    )

    Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"
    Switch-AzureMode AzureResourceManager

    $securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $servicePrincipalCredentials = New-Object System.Management.Automation.PSCredential ($ClientId, $securePassword)
    Add-AzureAccount -ServicePrincipal -Tenant $TenantId -Credential $servicePrincipalCredentials | Out-Null
}

function Clear-AzureAPICredentials {
    Param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId
    )

    Remove-AzureAccount -Name $ClientId -Force
}

function Get-AzureSQLConfig {
    Param(
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$PerformanceLevel
    )

    # https://msdn.microsoft.com/en-US/library/azure/dn505701
    switch ($PerformanceLevel) {
        Basic { return @{ Edition = "Basic"; ServiceObjectiveId = "dd6d99bb-f193-4ec1-86f2-43d3bccbc49c"}}
        S0 { return @{ Edition = "Standard"; ServiceObjectiveId = "f1173c43-91bd-4aaa-973c-54e79e15235b"}}
        S1 { return @{ Edition = "Standard"; ServiceObjectiveId = "1b1ebd4d-d903-4baa-97f9-4ea675f5e928"}}
        S2 { return @{ Edition = "Standard"; ServiceObjectiveId = "455330e1-00cd-488b-b5fa-177c226f28b7"}}
        S3 { return @{ Edition = "Standard"; ServiceObjectiveId = "789681b8-ca10-4eb0-bdf2-e0b050601b40"}}
        P1 { return @{ Edition = "Premium"; ServiceObjectiveId = "7203483a-c4fb-4304-9e9f-17c71c904f5d"}}
        P2 { return @{ Edition = "Premium"; ServiceObjectiveId = "a7d1b92d-c987-4375-b54d-2b1d0e0f5bb0"}}
        P3 { return @{ Edition = "Premium"; ServiceObjectiveId = "a7c4c615-cfb1-464b-b252-925be0a19446"}}
        Web { return @{ Edition = "Web"; ServiceObjectiveId = "910b4fcb-8a29-4c3e-958f-f7ba794388b2"}}
        Business { return @{ Edition = "Business"; ServiceObjectiveId = "910b4fcb-8a29-4c3e-958f-f7ba794388b2"}}
    }
}
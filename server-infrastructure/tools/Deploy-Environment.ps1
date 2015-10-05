#Requires -Version 4.0
# Also required: choco install windowsazurepowershell

Param(
    [string] [Parameter(Mandatory = $true)] $SubscriptionId,
    [string] [Parameter(Mandatory = $true)] $TenantId,
    [string] [Parameter(Mandatory = $true)] $ClientId,
    [string] [Parameter(Mandatory = $true)] $Password,
    [string] [Parameter(Mandatory = $true)] $Location,
    [string] [Parameter(Mandatory = $true)] $AppName,
    [string] [Parameter(Mandatory = $true)] $AppEnvironment,
    [string] [Parameter(Mandatory = $true)] $adminUsername,
    [string] [Parameter(Mandatory = $true)] $adminPassword,
    [string] [Parameter(Mandatory = $true)] $sqlServerAdminPassword,
    [string] $ResourceGroupName = "$AppName-$AppEnvironment-Resources",
    [string] $SqlPerformanceLevel = "S1",
    [string] $vmStorageAccountType = "Standard_LRS",
    [string] $vmSize = "Standard_A2"
)

try {

    $ErrorActionPreference = "Stop"
    Import-Module (Join-Path $PSScriptRoot AzureFunctions.psm1) -Force
    Set-AzureAPICredentials -TenantId $TenantId -ClientId $ClientId -Password $Password
    Select-AzureSubscription -SubscriptionId $SubscriptionId
    $TenantId = (Get-AzureSubscription -Current).TenantId
    Write-Output "Connected to Azure API"

    $vmName = "$AppName-$AppEnvironment-IIS"
    $sqlConfig = Get-AzureSqlConfig -PerformanceLevel $SqlPerformanceLevel
    $Parameters = @{
        location = $Location;
        vmStorageAccountName = "$($AppName)$($AppEnvironment)vm1".ToLower();
        vmStorageAccountType = "Standard_LRS";
        vmName = "IISFarm1";
        vmSize = $vmSize;
        adminUsername = $adminUsername;
        adminPassword = $adminPassword;
        sqlServerName = "$AppName-$AppEnvironment-sqlserver".ToLower();
        sqlServerAdminUsername = "$AppName-serveradmin".ToLower();
        sqlServerAdminPassword = $sqlServerAdminPassword;
        sqlDbName = "$AppName-$AppEnvironment";
        sqlDbEdition = $sqlConfig.Edition;
        sqlDbServiceObjectiveId = $sqlConfig.ServiceObjectiveId;
        networkDnsName = "$($AppName)$($AppEnvironment)VM1".ToLower();
    };

    $Parameters.GetEnumerator() | Sort-Object Name | ForEach-Object {ForEach-Object {"{0}`t{1}" -f $_.Name,($_.Value -join ", ")} | Write-Verbose }

    Write-Output "Ensuring resource group exists"
    New-AzureResourceGroup -Location $Location -Name $ResourceGroupName -Force | Out-Null

    Write-Output "Deploying resource group template"
    $result = New-AzureResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile "$PSScriptRoot\iis-tentacle.json" -TemplateParameterObject $Parameters -Name ("$AppName-$AppEnvironment-" + (Get-Date -Format "yyyy-MM-dd-HH-mm-ss")) -ErrorAction Continue
    Write-Output $result
    if ($result.ProvisioningState -ne "Succeeded") {
        throw "Deployment failed"
    }

} catch {
    $Host.UI.WriteErrorLine($_)
    exit 1
} finally {
    Write-Output "Disconnecting from Azure API"
    Clear-AzureAPICredentials -ClientId $ClientId
}

param($Timer)

if ($Timer.IsPastDue) {
  Write-Host "PowerShell timer is running late!"
}

# Set Service Principal credentials
$passwordSecure = ConvertTo-SecureString $env:SP_PASSWORD -AsPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential ($env:SP_USERNAME, $passwordSecure)
Connect-AzAccount -ServicePrincipal -Credential $credentials -Tenant $env:SP_TENANTID

# Find VM
$vm = Get-AzResource -ResourceType Microsoft.Compute/virtualMachines -ResourceGroup $env:VM_RESOURCE_GROUP -Tag @{role = 'mailbackup'} | Select -First 1

# Start VM
Write-Host "Starting VM $($vm.Id)..."
Start-AzVM -Id $vm.Id | Out-String

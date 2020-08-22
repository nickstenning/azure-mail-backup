param($Timer)

if ($Timer.IsPastDue) {
  Write-Host "PowerShell timer is running late!"
}

# Connect as the function app's managed identity
Connect-AzAccount -Identity

# Find VM
$vm = Get-AzResource -ResourceType Microsoft.Compute/virtualMachines -ResourceGroup $env:VM_RESOURCE_GROUP -Tag @{role = 'mailbackup'} | Select -First 1

# Start VM
Write-Host "Starting VM $($vm.Id)..."
Start-AzVM -Id $vm.Id | Out-String

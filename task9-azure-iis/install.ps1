# Variables for common values
$resourceGroup = "myResourceGroup"
$location = "westus"
$vmName = "myVM-task9"

# Create user object
$cred = Get-Credential -Message "Enter a username and password for the virtual machine."

# Create a resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Create a virtual machine
New-AzVM `
  -ResourceGroupName $resourceGroup `
  -Name $vmName `
  -Location $location `
  -ImageName "Win2016Datacenter" `
  -VirtualNetworkName "myVnet" `
  -SubnetName "mySubnet" `
  -SecurityGroupName "myNetworkSecurityGroup" `
  -PublicIpAddressName "myPublicIp" `
  -Credential $cred `
  -OpenPorts 80, 3389 `
  -Size "Standard_D1"

# Install IIS
$PublicSettings = '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'

Set-AzVMExtension `
  -ExtensionName "IIS" `
  -ResourceGroupName $resourceGroup `
  -VMName $vmName `
  -Publisher "Microsoft.Compute" `
  -ExtensionType "CustomScriptExtension" `
  -TypeHandlerVersion 1.4 `
  -SettingString $PublicSettings `
  -Location $location  ;
  
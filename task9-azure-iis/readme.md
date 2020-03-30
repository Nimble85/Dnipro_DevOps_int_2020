# TASK
1. Create VNet, VM, Loadbalancer, IIS server via Azure Portal.     
2. Create IIS server via ARM template.     
3. Change IIS default start page (ARM template or custom script).     

# Solution
## 1. Create VNet, VM, Loadbalancer, IIS server via Azure Portal. 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic1.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic2.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic3.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic4.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic5.png)

## 2 Create IIS server via ARM template. with using the DSC extension.
 DSC extension file IISWebserver.ps1
 ```
 Configuration IISWebServer
{
    param ($MachineName)
    Node $MachineName
    {
        WindowsFeature IIS 
        {
            Ensure = "Present"
            Name   = "Web-Server"
        }
    }
} 
```

file azuredeploy.json
```
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "diskType": {
        "type": "string",
        "defaultValue": "Standard_LRS",
        "allowedValues": [
          "Standard_LRS",
          "Premium_LRS"
        ],
        "metadata": {
          "description": "Type of the Storage for disks"
        }
      },
      "vmName": {
        "type": "string",
        "metadata": {
          "description": "Name of the VM"
        }
      },
      "vmSize": {
        "type": "string",
        "defaultValue": "Standard_A2",
        "metadata": {
          "description": "Size of the VM"
        }
      },
      "imageSKU": {
        "type": "string",
        "defaultValue": "2012-R2-Datacenter",
        "allowedValues": [
          "2008-R2-SP1",
          "2012-Datacenter",
          "2012-R2-Datacenter"
        ],
        "metadata": {
          "description": "Image SKU"
        }
      },
      "adminUsername": {
        "type": "string",
        "metadata": {
          "description": "Admin username"
        }
      },
      "adminPassword": {
        "type": "securestring",
        "metadata": {
          "description": "Admin password"
        }
      },
      "modulesUrl": {
        "type": "string",
        "metadata": {
          "description": "URL for the DSC configuration module. NOTE: Can be a Github url(raw) to the zip file"
        }
      },
      "configurationFunction": {
        "type": "string",
        "defaultValue": "ContosoWebsite.ps1\\ContosoWebsite",
        "metadata": {
          "description": "DSC configuration function to call"
        }
      },
      "location": {
        "type": "string",
        "defaultValue": "[resourceGroup().location]",
        "metadata": {
          "description": "Location for all resources."
        }
      }
    },
    "variables": {
      "virtualNetworkName": "dscVNET",
      "vnetID": "[resourceId('Microsoft.Network/virtualNetworks', variables('virtualNetworkName'))]",
      "vnetAddressPrefix": "10.0.0.0/16",
      "subnet1Name": "dscSubnet-1",
      "subnet1Prefix": "10.0.0.0/24",
      "subnet1Ref": "[concat(variables('vnetID'),'/subnets/', variables('subnet1Name'))]",
      "publicIPAddressType": "Dynamic",
      "publicIPAddressName": "dscPubIP",
      "nicName": "dscNIC",
      "imagePublisher": "MicrosoftWindowsServer",
      "imageOffer": "WindowsServer",
      "vmExtensionName": "dscExtension",
      "networkSecurityGroupName": "default-NSG"
    },
    "resources": [
      {
        "apiVersion": "2015-05-01-preview",
        "type": "Microsoft.Network/publicIPAddresses",
        "name": "[variables('publicIPAddressName')]",
        "location": "[parameters('location')]",
        "properties": {
          "publicIPAllocationMethod": "[variables('publicIPAddressType')]"
        }
      },
      {
        "comments": "Default Network Security Group for template",
        "type": "Microsoft.Network/networkSecurityGroups",
        "apiVersion": "2019-08-01",
        "name": "[variables('networkSecurityGroupName')]",
        "location": "[parameters('location')]",
        "properties": {
          "securityRules": [
            {
              "name": "default-allow-80",
              "properties": {
                "priority": 1000,
                "access": "Allow",
                "direction": "Inbound",
                "destinationPortRange": "80",
                "protocol": "Tcp",
                "sourceAddressPrefix": "*",
                "sourcePortRange": "*",
                "destinationAddressPrefix": "*"
              }
            },
            {
              "name": "default-allow-3389",
              "properties": {
                "priority": 1001,
                "access": "Allow",
                "direction": "Inbound",
                "destinationPortRange": "3389",
                "protocol": "Tcp",
                "sourceAddressPrefix": "*",
                "sourcePortRange": "*",
                "destinationAddressPrefix": "*"
              }
            }
          ]
        }
      },
      {
        "apiVersion": "2015-05-01-preview",
        "type": "Microsoft.Network/virtualNetworks",
        "name": "[variables('virtualNetworkName')]",
        "location": "[parameters('location')]",
        "dependsOn": [
          "[resourceId('Microsoft.Network/networkSecurityGroups', variables('networkSecurityGroupName'))]"
        ],
        "properties": {
          "addressSpace": {
            "addressPrefixes": [
              "[variables('vnetAddressPrefix')]"
            ]
          },
          "subnets": [
            {
              "name": "[variables('subnet1Name')]",
              "properties": {
                "addressPrefix": "[variables('subnet1Prefix')]",
                "networkSecurityGroup": {
                  "id": "[resourceId('Microsoft.Network/networkSecurityGroups', variables('networkSecurityGroupName'))]"
                }
              }
            }
          ]
        }
      },
      {
        "apiVersion": "2015-05-01-preview",
        "type": "Microsoft.Network/networkInterfaces",
        "name": "[variables('nicName')]",
        "location": "[parameters('location')]",
        "dependsOn": [
          "[concat('Microsoft.Network/publicIPAddresses/', variables('publicIPAddressName'))]",
          "[concat('Microsoft.Network/virtualNetworks/', variables('virtualNetworkName'))]"
        ],
        "properties": {
          "ipConfigurations": [
            {
              "name": "ipconfig1",
              "properties": {
                "privateIPAllocationMethod": "Dynamic",
                "publicIPAddress": {
                  "id": "[resourceId('Microsoft.Network/publicIPAddresses', variables('publicIPAddressName'))]"
                },
                "subnet": {
                  "id": "[variables('subnet1Ref')]"
                }
              }
            }
          ]
        }
      },
      {
        "apiVersion": "2017-03-30",
        "type": "Microsoft.Compute/virtualMachines",
        "name": "[parameters('vmName')]",
        "location": "[parameters('location')]",
        "dependsOn": [
          "[concat('Microsoft.Network/networkInterfaces/', variables('nicName'))]"
        ],
        "properties": {
          "hardwareProfile": {
            "vmSize": "[parameters('vmSize')]"
          },
          "osProfile": {
            "computerName": "[parameters('vmName')]",
            "adminUsername": "[parameters('adminUsername')]",
            "adminPassword": "[parameters('adminPassword')]"
          },
          "storageProfile": {
            "imageReference": {
              "publisher": "[variables('imagePublisher')]",
              "offer": "[variables('imageOffer')]",
              "sku": "[parameters('imageSKU')]",
              "version": "latest"
            },
            "osDisk": {
              "name": "[concat(parameters('vmName'), '_OSDisk')]",
              "caching": "ReadWrite",
              "createOption": "FromImage",
              "managedDisk": {
                "storageAccountType": "[parameters('diskType')]"
              }
            }
          },
          "networkProfile": {
            "networkInterfaces": [
              {
                "id": "[resourceId('Microsoft.Network/networkInterfaces', variables('nicName'))]"
              }
            ]
          }
        }
      },
      {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": "[concat(parameters('vmName'),'/', variables('vmExtensionName'))]",
        "apiVersion": "2015-05-01-preview",
        "location": "[parameters('location')]",
        "dependsOn": [
          "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"
        ],
        "properties": {
          "publisher": "Microsoft.Powershell",
          "type": "DSC",
          "typeHandlerVersion": "2.19",
          "autoUpgradeMinorVersion": true,
          "settings": {
            "ModulesUrl": "[parameters('modulesUrl')]",
            "ConfigurationFunction": "[parameters('configurationFunction')]",
            "Properties": {
              "MachineName": "[parameters('vmName')]"
            }
          },
          "protectedSettings": null
        }
      }
    ]
  }
  ```
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic12.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic13.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic13-1.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic14.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic15.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic16.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic17.png)

## 3. create VM and change default page

I make it via Cloud Shell
file install.ps1
```
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
  -Location $location 
  ```
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic9.png) 
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic10.png)
![](https://github.com/fenixra73/Dnipro_DevOps_int_2020/raw/master/task9-azure-iis/screenshot/pic11.png)




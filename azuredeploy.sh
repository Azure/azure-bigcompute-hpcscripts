{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "dnsLabelPrefix": {
      "type": "string",
      "defaultValue": "shellazure",
      "metadata": {
        "description": "Unique public dns prefix where the  node will be exposed"
      }
    },
    "adminUserName": {
      "type": "string",
      "defaultValue": "azureuser",
      "metadata": {
        "description": "User name for the Virtual Machine. Pick a valid username otherwise there will be a BadRequest error."
      }
    },
    "imagePublisher": {
      "type": "string",
      "defaultValue": "Canonical",
      "allowedValues": [
        "Canonical",
        "openlogic"
      ],
      "metadata": {
        "description": "openlogic/Canonical is the CentOS/Ubuntu Distributor in Azure Market Place"
      }
    },
    "imageOffer": {
      "type": "string",
      "defaultValue": "UbuntuServer",
      "allowedValues": [
        "CentOS-HPC",
        "UbuntuServer"
      ],
      "metadata": {
        "description": "New CentOS-HPC/UbuntuServer with pre-installed Intel MPI and mlx4 drivers on Infiniband Available"
      }
    },
    "imageSku": {
      "type": "string",
      "defaultValue": "16.04.0-LTS",
      "allowedValues": [
        "6.5",
        "7.1",
        "16.04.0-LTS"
      ],
      "metadata": {
        "description": "OpenLogic CentOS-HPC Sku to use"
      }
    },
    "sshPublicKey": {
      "type": "securestring",
      "metadata": {
        "description": "This field must be a valid SSH public key. ssh with this RSA public key"
      }
    },
    "mountFolder": {
      "type": "string",
      "defaultValue": "/data",
      "metadata": {
        "description": "The Folder system to be auto-mounted."
      }
    },
    "hpcUserName": {
      "type": "string",
      "defaultValue": "hpc",
      "metadata": {
        "description": "User for running HPC applications with shared home directory and SSH public key authentication setup.  This user cannot login from outside the cluster. Pick a valid username otherwise there will be a BadRequest error."
      }
    },
    "MUNGE_VER": {
      "type": "string",
      "defaultValue": "0.5.11",
      "metadata": {
        "description": "The MUNGE Version - This is a yum install."
      }
    },
    "SLURM_VER": {
      "type": "string",
      "defaultValue": "15-08-10-1",
      "metadata": {
        "description": "The SLURM version - WIP Please Ignore for now."
      }
    },
    "MUNGE_USER_GROUP": {
      "type": "string",
      "defaultValue": "munge",
      "metadata": {
        "description": "The MUNGE user ."
      }
    },
    "SLURM_USER_GROUP": {
      "type": "string",
      "defaultValue": "slurm",
      "metadata": {
        "description": "The SLURM user ."
      }
    },
    "headNodeSize": {
      "type": "string",
      "defaultValue": "Standard_NC12",
      "allowedValues": [
        "Standard_NC12",
        "Standard_NC24",
        "Standard_A8",
        "Standard_A9"
      ],
      "metadata": {
        "description": "Size of the head node."
      }
    },
    "workerNodeSize": {
      "type": "string",
      "defaultValue": "Standard_NC24",
      "allowedValues": [
        "Standard_NC12",
        "Standard_NC24",
        "Standard_A8",
        "Standard_A9"
      ],
      "metadata": {
        "description": "Size of the worker nodes."
      }
    },
    "workerNodeCount": {
      "type": "int",
      "defaultValue": 8,
      "metadata": {
        "description": "This template creates N worker node. Use workerNodeCount to specify that N."
      }
    },
    "storageType": {
      "type": "string",
      "allowedValues": [
        "Standard_LRS",
        "Premium_LRS",
        "Standard_GRS",
        "Standard_RAGRS",
        "Standard_ZRS"
      ],
      "defaultValue": "Standard_LRS",
      "metadata": {
        "description": "Storage Account Type : Standard-LRS, Standard-GRS, Standard-RAGRS, Standard-ZRS, Premium_LRS - Striping rules Apply"
      }
    },
    "dockerVer": {
      "type": "string",
      "defaultValue": "1.12.1-1",
      "metadata": {
        "description": "The docker version **Only for CentOS-HPC 7.1 - kernels 3.10 and above **"
      }
    },
    "dockerComposeVer": {
      "type": "string",
      "defaultValue": "1.8.0",
      "metadata": {
        "description": "The Docker Compose Version **Only for CentOS-HPC 7.1-  kernels 3.10 and above **"
      }
    },
    "dockerMachineVer": {
      "type": "string",
      "defaultValue": "0.8.1",
      "metadata": {
        "description": "The docker-machine version **Only for CentOS-HPC 7.1- kernels 3.10 and above **"
      }
    },
    "dataDiskSize": {
      "type": "int",
      "defaultValue": 1022,
      "metadata": {
        "description": "The size in GB of each data disk that is attached to the VM.  A MDADM RAID0  is created with all data disks auto-mounted,  that is dataDiskSize * dataDiskCount in size n the Storage."
      }
    },
    "masterVMName": {
      "type": "string",
      "defaultValue": "headN",
      "metadata": {
        "description": "The Name of the VM."
      }
    },
    "workerVMNamePrefix": {
      "type": "string",
      "defaultValue": "compN",
      "metadata": {
        "description": "The Name Prefix of the worker(s) VM Nodes which whould be suffixed by the worker number."
      }
    },
    "numDataDisks": {
      "type": "string",
      "defaultValue": "16",
      "allowedValues": [
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "11",
        "12",
        "13",
        "14",
        "15",
        "16"
      ],
      "metadata": {
        "description": "This parameter allows the user to select the number of disks they want"
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts",
      "name": "[variables('newStorageAccountName')]",
      "apiVersion": "[variables('armApiVersion')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "accountType": "[parameters('storageType')]"
      }
    },
    {
      "type": "Microsoft.Compute/availabilitySets",
      "name": "[variables('avSetName')]",
      "apiVersion": "[variables('armApiVersion')]",
      "location": "[resourceGroup().location]",
      "properties": { }
    },
    {
      "apiVersion": "[variables('armApiVersion')]",
      "type": "Microsoft.Network/virtualNetworks",
      "name": "[variables('networkSettings').virtualNetworkName]",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[variables('networkSettings').addressPrefix]"
          ]
        },
        "subnets": [
          {
            "name": "[variables('networkSettings').subnet.dse.name]",
            "properties": {
              "addressPrefix": "[variables('networkSettings').subnet.dse.prefix]"
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Network/publicIPAddresses",
      "apiVersion": "[variables('armApiVersion')]",
      "name": "[variables('publicIPAddressName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "publicIPAllocationMethod": "[variables('publicIPAddressType')]",
        "dnsSettings": {
          "domainNameLabel": "[parameters('dnsLabelPrefix')]"
        }
      }
    },
    {
      "apiVersion": "[variables('armApiVersion')]",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[variables('nicName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Network/publicIPAddresses/', variables('publicIPAddressName'))]",
        "[concat('Microsoft.Network/virtualNetworks/', variables('networkSettings').virtualNetworkName)]"
      ],
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Static",
              "privateIPAddress": "[variables('networkSettings').statics.master]",
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses',variables('publicIPAddressName'))]"
              },
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
    {
      "apiVersion": "[variables('armApiVersion')]",
      "type": "Microsoft.Compute/virtualMachines",
      "name": "[parameters('masterVMName')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Storage/storageAccounts/', variables('newStorageAccountName'))]",
        "[concat('Microsoft.Network/networkInterfaces/', variables('nicName'))]",
        "[concat('Microsoft.Compute/availabilitySets/', variables('avSetName'))]",
        "[concat('Microsoft.Resources/deployments/', 'diskSelection')]"
      ],
      "properties": {
        "availabilitySet": {
          "id": "[resourceId('Microsoft.Compute/availabilitySets', variables('avSetName'))]"
        },
        "hardwareProfile": {
          "vmSize": "[parameters('headNodeSize')]"
        },
        "osProfile": {
          "computername": "[parameters('masterVMName')]",
          "adminUsername": "[parameters('adminUsername')]",
          "linuxConfiguration": {
            "disablePasswordAuthentication": "true",
            "ssh": {
              "publicKeys": [
                {
                  "path": "[variables('sshKeyPath')]",
                  "keyData": "[parameters('sshPublicKey')]"
                }
              ]
            }
          }
        },
        "storageProfile": {
          "dataDisks": "[reference('diskSelection').outputs.dataDiskArray.value]",
          "imageReference": {
            "publisher": "[parameters('imagePublisher')]",
            "offer": "[parameters('imageOffer')]",
            "sku": "[parameters('imageSku')]",
            "version": "latest"
          },
          "osDisk": {
            "name": "osdisk",
            "vhd": {
              "uri": "[concat('http://',variables('newStorageAccountName'),'.blob.core.windows.net/',variables('vmStorageAccountContainerName'),'/',variables('OSDiskName'),parameters('masterVMName'),'.vhd')]"
            },
            "caching": "ReadWrite",
            "createOption": "FromImage"
          }
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces',variables('nicName'))]"
            }
          ]
        }
      }
    },
    {
      "apiVersion": "[variables('armApiVersion')]",
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "name": "[concat(parameters('masterVMName'), '/Installation')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/', parameters('masterVMName'))]"
      ],
      "properties": {
        "publisher": "Microsoft.Azure.Extensions",
        "type": "CustomScript",
        "typeHandlerVersion": "2.0",
        "autoUpgradeMinorVersion": true,
        "settings": {
          "fileUris": [
            "[concat(variables('artifactsLocation'), 'azuredeploy.sh')]"
          ],
          "commandToExecute": "[variables('installationCLI')]"
        }
      }
    },
    {
      "apiVersion": "[variables('armApiVersion')]",
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "name": "[concat(parameters('workerVMNamePrefix'), copyindex(), '/Installation')]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/', parameters('masterVMName'),'/extensions/Installation')]",
        "[concat('Microsoft.Compute/virtualMachines/', parameters('workerVMNamePrefix'), copyindex())]"
      ],
      "copy": {
        "name": "foo",
        "count": "[parameters('workerNodeCount')]"
      },
      "properties": {
        "publisher": "Microsoft.OSTCExtensions",
        "type": "CustomScriptForLinux",
        "typeHandlerVersion": "1.5",
        "autoUpgradeMinorVersion": true,
        "settings": {
          "fileUris": [
            "[concat(variables('artifactsLocation'), 'azuredeploy.sh')]"
          ],
          "commandToExecute": "[variables('installationCLI')]"
        }
      }
    },
    {
      "apiVersion": "[variables('armApiVersion')]",
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[concat('nic', parameters('workerVMNamePrefix'), copyindex())]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Network/virtualNetworks/', variables('networkSettings').virtualNetworkName)]"
      ],
      "copy": {
        "name": "foo",
        "count": "[parameters('workerNodeCount')]"
      },
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Static",
              "privateIPAddress": "[concat(variables('networkSettings').statics.workerRange.base, copyindex(variables('networkSettings').statics.workerRange.start))]",
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ]
      }
    },
    {
      "apiVersion": "[variables('armApiVersion')]",
      "type": "Microsoft.Compute/virtualMachines",
      "name": "[concat(parameters('workerVMNamePrefix'), copyindex())]",
      "location": "[resourceGroup().location]",
      "dependsOn": [
        "[concat('Microsoft.Storage/storageAccounts/', variables('newStorageAccountName'))]",
        "[concat('Microsoft.Network/networkInterfaces/', variables('nicName'), parameters('workerVMNamePrefix'), copyindex())]",
        "[concat('Microsoft.Compute/availabilitySets/', variables('avSetName'))]"
      ],
      "copy": {
        "name": "foo",
        "count": "[parameters('workerNodeCount')]"
      },
      "properties": {
        "availabilitySet": {
          "id": "[resourceId('Microsoft.Compute/availabilitySets', variables('avSetName'))]"
        },
        "hardwareProfile": {
          "vmSize": "[parameters('workerNodeSize')]"
        },
        "osProfile": {
          "computername": "[concat(parameters('workerVMNamePrefix'), copyindex())]",
          "adminUsername": "[parameters('adminUsername')]",
          "linuxConfiguration": {
            "disablePasswordAuthentication": "true",
            "ssh": {
              "publicKeys": [
                {
                  "path": "[variables('sshKeyPath')]",
                  "keyData": "[parameters('sshPublicKey')]"
                }
              ]
            }
          }
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[parameters('imagePublisher')]",
            "offer": "[parameters('imageOffer')]",
            "sku": "[parameters('imageSku')]",
            "version": "latest"
          },
          "osDisk": {
            "name": "osdisk",
            "vhd": {
              "uri": "[concat('http://',variables('newStorageAccountName'),'.blob.core.windows.net/',variables('vmStorageAccountContainerName'),'/',variables('OSDiskName'),parameters('workerVMNamePrefix'),copyindex(),'.vhd')]"
            },
            "caching": "ReadWrite",
            "createOption": "FromImage"
          }
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces',concat('nic', parameters('workerVMNamePrefix'), copyindex()))]"
            }
          ]
        }
      }
    },
    {
      "apiVersion": "2015-01-01",
      "name": "diskSelection",
      "type": "Microsoft.Resources/deployments",
      "properties": {
        "mode": "Incremental",
        "templateLink": {
          "uri": "[concat(variables('artifactsLocation'), 'diskSelection', '.json')]",
          "contentVersion": "1.0.0.0"
        },
        "parameters": {
          "numberofDataDisks": {
            "value": "[parameters('numDataDisks')]"
          },
          "diskStorageAccountName": {
            "value": "[variables('newStorageAccountName')]"
          },
          "diskCaching": {
            "value": "[variables('diskCaching')]"
          },
          "diskSizeGB": {
            "value": "[parameters('dataDiskSize')]"
          },
          "vmStAccountContainerName": {
            "value": "[variables('vmStorageAccountContainerName')]"
          },
          "masterName": {
            "value": "[parameters('masterVMName')]"
          }
        }
      }
    }
  ],
  "variables": {
    "armApiVersion": "2015-06-15",
    "artifactsLocation": "https://raw.githubusercontent.com/Azure/azure-bigcompute-hpcscripts/master/",
    "avSetName": "avSet",
    "diskCaching": "ReadWrite",
    "mungedet": "[concat(parameters('MUNGE_VER'), ':', parameters('MUNGE_USER_GROUP'))]",
    "slurmdet": "[concat(parameters('SLURM_VER'), ':', parameters('SLURM_USER_GROUP'))]",
    "dockerdet": "[concat(parameters('dockerVer'), ':', parameters('dockerComposeVer'), ':', parameters('dockerMachineVer'))]",
    "imagedet": "[concat(parameters('imageSku'), ':', parameters('adminUserName'))]",
    "clusterdet": "[concat(parameters('MasterVMName'), ':', parameters('workerVMNamePrefix'), ':', parameters('WorkerNodeCount'))]",
    "installationCLI": "[concat('bash azuredeploy.sh ', variables('clusterdet'), ' ', parameters('HPCUserName'), ' ', parameters('mountFolder'), ' ', variables('mungedet'), ' ', variables('slurmdet'), ' ', parameters('numDataDisks'), ' ', variables('dockerdet'), ' ', variables('imagedet'), ' ', variables('artifactsLocation'))]",
    "networkSettings": {
      "virtualNetworkName": "virtualnetwork",
      "addressPrefix": "10.0.0.0/16",
      "subnet": {
        "dse": {
          "name": "dse",
          "prefix": "10.0.0.0/24",
          "vnet": "virtualnetwork"
        }
      },
      "statics": {
        "workerRange": {
          "base": "10.0.0.",
          "start": 5
        },
        "master": "10.0.0.254"
      }
    },
    "newStorageAccountName": "[concat(uniqueString(resourceGroup().id), 'dynamicdisk')]",
    "nicName": "nic",
    "OSDiskName": "osdisk",
    "publicIPAddressName": "publicips",
    "publicIPAddressType": "Dynamic",
    "sshKeyPath": "[concat('/home/',parameters('adminUserName'),'/.ssh/authorized_keys')]",
    "subnetRef": "[concat(variables('vnetID'),'/subnets/',variables('networkSettings').subnet.dse.name)]",
    "vmStorageAccountContainerName": "vhd",
    "vnetID": "[resourceId('Microsoft.Network/virtualNetworks',variables('networkSettings').virtualNetworkName)]"
  }
}

@description('VMSS name')
param vmssName string = 'vmss-commerce-web'

@description('Azure region')
param location string = 'eastus'

@description('Existing web subnet resource ID')
param subnetId string

@description('Existing web NSG resource ID')
param networkSecurityGroupId string

@description('Existing Load Balancer backend pool resource ID')
param loadBalancerBackendPoolId string

@description('Linux administrator username')
param adminUsername string = 'azureuser'

@description('SSH public key for the administrator')
@secure()
param adminSshPublicKey string

@description('Number of VMSS instances')
param instanceCount int = 2

@description('VM size')
param vmSize string = 'Standard_F1als_v7'


resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: vmssName
  location: location

  zones: [
    '1'
    '2'
  ]

  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: instanceCount
  }

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    orchestrationMode: 'Uniform'

    upgradePolicy: {
      mode: 'Manual'
    }

    overprovision: false

    virtualMachineProfile: {

      osProfile: {
        computerNamePrefix: 'commerceweb'

        adminUsername: adminUsername

        linuxConfiguration: {
          disablePasswordAuthentication: true

          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminSshPublicKey
              }
            ]
          }
        }
      }

      storageProfile: {
        imageReference: {
          publisher: 'Canonical'
          offer: 'ubuntu-24_04-lts'
          sku: 'server'
          version: 'latest'
        }

        osDisk: {
          createOption: 'FromImage'
          diskSizeGB: 30

          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }

          caching: 'ReadWrite'
        }
      }

      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'vnet-commerce-nic01'

            properties: {
              primary: true

              enableAcceleratedNetworking: true

              networkSecurityGroup: {
                id: networkSecurityGroupId
              }

              ipConfigurations: [
                {
                  name: 'vnet-commerce-nic01-defaultIpConfiguration'

                  properties: {
                    primary: true

                    privateIPAddressVersion: 'IPv4'

                    subnet: {
                      id: subnetId
                    }

                    loadBalancerBackendAddressPools: [
                      {
                        id: loadBalancerBackendPoolId
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }

      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
    }
  }
}


output vmssName string = vmss.name
output vmssId string = vmss.id
output principalId string = vmss.identity.principalId


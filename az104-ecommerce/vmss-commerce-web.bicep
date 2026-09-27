@description('Azure region')
param location string = 'eastus'

@description('VM Scale Set name')
param vmssName string = 'vmss-commerce-web'

@description('Existing web subnet resource ID')
param subnetId string

@description('Existing Load Balancer backend pool resource ID')
param loadBalancerBackendPoolId string

@description('VM administrator username')
param adminUsername string = 'azureuser'

@description('SSH public key')
param adminSshPublicKey string

@description('Number of VMSS instances')
param instanceCount int = 2

@description('VM size')
param vmSize string = 'Standard_B2s'


resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: vmssName
  location: location

  sku: {
    name: vmSize
    tier: 'Standard'
    capacity: instanceCount
  }

  zones: [
    '1'
    '2'
  ]

  identity: {
    type: 'SystemAssigned'
  }

  properties: {

    // -----------------------------------------------------
    // Upgrade policy
    // -----------------------------------------------------

    upgradePolicy: {
      mode: 'Manual'
    }

    // -----------------------------------------------------
    // Overprovisioning
    // -----------------------------------------------------

    overprovision: true

    // -----------------------------------------------------
    // Zone distribution
    // -----------------------------------------------------

    zoneBalance: true

    // -----------------------------------------------------
    // Virtual machine profile
    // -----------------------------------------------------

    virtualMachineProfile: {

      // ---------------------------------------------------
      // OS
      // ---------------------------------------------------

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

      // ---------------------------------------------------
      // Image / OS disk
      // ---------------------------------------------------

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
        }
      }

      // ---------------------------------------------------
      // Networking
      // ---------------------------------------------------

      networkProfile: {

        networkInterfaceConfigurations: [
          {
            name: 'nic-commerce-web'

            properties: {
              primary: true

              enableAcceleratedNetworking: true

              ipConfigurations: [
                {
                  name: 'ipconfig1'

                  properties: {

                    subnet: {
                      id: subnetId
                    }

                    // Connect VMSS instances to the
                    // existing Load Balancer backend pool.
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

      // ---------------------------------------------------
      // Boot diagnostics
      // ---------------------------------------------------

      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
    }
  }
}


// ---------------------------------------------------------
// OUTPUTS
// ---------------------------------------------------------

output vmssId string = vmss.id

output vmssName string = vmss.name

output principalId string = vmss.identity.principalId


targetScope = 'resourceGroup'

param adminSshPublicKey string

var location = 'eastus'

var subnetId = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  'vnet-commerce',
  'snet-web'
)

var webNsgId = resourceId(
  'Microsoft.Network/networkSecurityGroups',
  'nsg-commerce-web'
)

var loadBalancerBackendPoolId = resourceId(
  'Microsoft.Network/loadBalancers/backendAddressPools',
  'lb-commerce-web',
  'bepool'
)

module webVmss './modules/vmss-commerce-web.bicep' = {
  name: 'deploy-commerce-web-vmss'

  params: {
    location: location
    vmssName: 'vmss-commerce-web'

    subnetId: subnetId
    networkSecurityGroupId: webNsgId
    loadBalancerBackendPoolId: loadBalancerBackendPoolId

    adminUsername: 'azureuser'
    adminSshPublicKey: adminSshPublicKey

    instanceCount: 2
    vmSize: 'Standard_F1als_v7'
  }
}

output vmssName string = webVmss.outputs.vmssName
output vmssId string = webVmss.outputs.vmssId
output principalId string = webVmss.outputs.principalId


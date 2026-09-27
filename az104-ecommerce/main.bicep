@description('Azure region for the deployment')
param location string = 'eastus'

@description('Resource group name')
param resourceGroupName string = 'rg-commerece-group'

@description('Virtual network address space')
param vnetAddressPrefix string = '172.16.0.0/16'

@description('Web subnet address prefix')
param webSubnetPrefix string = '172.16.1.0/24'

@description('Application subnet address prefix')
param appSubnetPrefix string = '172.16.2.0/24'

@description('Data subnet address prefix')
param dataSubnetPrefix string = '172.16.3.0/24'


// ---------------------------------------------------------
// NETWORK SECURITY GROUPS
// ---------------------------------------------------------

resource webNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-commerce-web'
  location: location

  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-HTTPS'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-AzureLoadBalancer'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


resource appNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-commerce-app'
  location: location

  properties: {
    securityRules: [
      {
        name: 'Allow-App-From-Web'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '172.16.1.0/24'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


resource dataNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-commerce-data'
  location: location

  properties: {
    securityRules: [
      {
        name: 'Allow-SQL-From-App'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '1433'
          sourceAddressPrefix: '172.16.2.0/24'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}


// ---------------------------------------------------------
// VIRTUAL NETWORK
// ---------------------------------------------------------

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-commerce'
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }

    subnets: [
      {
        name: 'snet-web'
        properties: {
          addressPrefix: webSubnetPrefix
          networkSecurityGroup: {
            id: webNsg.id
          }
        }
      }
      {
        name: 'snet-app'
        properties: {
          addressPrefix: appSubnetPrefix
          networkSecurityGroup: {
            id: appNsg.id
          }
        }
      }
      {
        name: 'snet-data'
        properties: {
          addressPrefix: dataSubnetPrefix
          networkSecurityGroup: {
            id: dataNsg.id
          }
        }
      }
    ]
  }
}


// ---------------------------------------------------------
// OUTPUTS
// ---------------------------------------------------------

output vnetName string = vnet.name
output vnetId string = vnet.id

output webSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnet.name,
  'snet-web'
)

output appSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnet.name,
  'snet-app'
)

output dataSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnet.name,
  'snet-data'
)


Checkpoint 02 — Web VMSS
Objective

Deploy the web-tier Virtual Machine Scale Set (VMSS) for the Azure e-commerce platform.

The VMSS is designed to provide:

Multiple VM instances

Availability Zone distribution

Load Balancer integration

Private VM networking

NSG-based traffic control

Managed identity support

Ubuntu Linux workloads

Environment
Setting	Value
Subscription	Azure subscription 1
Resource Group	rg-commerece-group
Region	East US
VMSS	vmss-skabiral
VNet	vnet-commerce
Web Subnet	snet-web
Web Subnet CIDR	172.16.1.0/24
Load Balancer	lb-commerce-web
Backend Pool	bepool
VM Size	Standard_F1als_v7
Image	Ubuntu Server 24.04 LTS Gen2
OS Disk	Premium SSD LRS
Orchestration	Uniform
Upgrade Mode	Manual
Availability Zones	1 and 2
Initial Instance Count	2
Deployment Method 1 — Azure Portal

The VMSS was created through the Azure Portal.

Basics

Configured:

Resource group: rg-commerece-group

VMSS name: vmss-skabiral

Region: East US

Availability Zones: 1 and 2

Uniform orchestration

Ubuntu Server 24.04 LTS Gen2

Standard_F1als_v7

Manual scaling

2 initial instances

SSH public key authentication

Username: azureuser

Standard security type

Azure Spot disabled

Disks

Configured:

Image-default OS disk size

Premium SSD LRS

Managed disks

Ephemeral OS disk disabled

NVMe disk controller

Networking

Configured:

VNet: vnet-commerce

Subnet: snet-web

Load Balancer: lb-commerce-web

Backend pool: bepool

Accelerated networking enabled

No public IP configuration on VMSS instances

The Load Balancer provides the public entry point while the VMSS instances use private IP addressing.

Management

Configured:

Manual upgrade mode

Boot diagnostics enabled

System-assigned managed identity enabled

Microsoft Entra ID login disabled

Standby pools disabled

Overprovisioning disabled

Automatic OS upgrades disabled

Health

Application health monitoring was initially disabled.

Automatic instance repair was disabled.

Advanced

Configured:

Scaling beyond 100 instances enabled

Max spreading

Fault domain count: 1

No proximity placement group

No capacity reservation

No VM extensions

No cloud-init

Deployment Validation

The VMSS was successfully deployed with two instances.

Command:

az vmss show \
  --resource-group rg-commerece-group \
  --name vmss-skabiral \
  --query "{
    name:name,
    location:location,
    zones:zones,
    sku:sku.name,
    capacity:sku.capacity,
    orchestration:orchestrationMode,
    upgradeMode:upgradePolicy.mode
  }" \
  --output yaml


Result:

capacity: 2
location: eastus
name: vmss-skabiral
orchestration: Uniform
sku: Standard_F1als_v7
upgradeMode: Manual
zones:
- '1'
- '2'

Instance Validation
az vmss list-instances \
  --resource-group rg-commerece-group \
  --name vmss-skabiral \
  --query "[].{Instance:instanceId,Zone:zones[0],State:instanceView.statuses[1].displayStatus}" \
  --output table


Result:

Instance    Zone
----------  ------
0           1
1           2


This confirms the VMSS has instances distributed across Availability Zones 1 and 2.

Public IP Validation

The VMSS was initially affected by a subscription public IP quota issue.

The Portal-created VMSS was subsequently configured without public IP addresses on the VMSS NIC configuration.

Validation:

az vmss show \
  --resource-group rg-commerece-group \
  --name vmss-skabiral \
  --query "virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].ipConfigurations[0].publicIPAddressConfiguration" \
  --output json


No public IP configuration was returned.

The architecture therefore uses:

Internet
   |
   v
Load Balancer Public IP
   |
   v
Load Balancer
   |
   v
VMSS Backend Pool
   |
   +--> VMSS Instance 0
   |
   +--> VMSS Instance 1


The VMSS instances themselves do not require individual public IP addresses.

Load Balancer Integration

The VMSS is attached to the existing Load Balancer backend pool.

Validation:

az vmss show \
  --resource-group rg-commerece-group \
  --name vmss-skabiral \
  --query "virtualMachineProfile.networkProfile.networkInterfaceConfigurations[0].ipConfigurations[0].loadBalancerBackendAddressPools[].id" \
  --output tsv


Backend pool:

lb-commerce-web/backendAddressPools/bepool

NSG Configuration

The intended web-tier NSG is:

nsg-commerce-web


It is attached to:

snet-web


The NSG contains rules for:

HTTP / TCP 80

HTTPS / TCP 443

Azure Load Balancer

Virtual Network traffic

Default inbound deny

The Portal initially created:

basicNsgvnet-commerce-nic01


at the VMSS network-interface level.

The VMSS model was subsequently updated so that the NIC-level NSG association was removed.

At the time of this checkpoint, the existing VMSS instance NICs may still retain the automatically-created NSG association and are being reimaged to reconcile the instances with the updated VMSS model.

This is being investigated as part of the networking configuration exercise.

Lessons Learned
VMSS model vs. VM instances

A VMSS has a model defining how instances should be configured.

Changing the VMSS model does not necessarily mean every existing instance immediately has identical configuration.

This was demonstrated when the VMSS model no longer referenced the automatically-created NSG while existing VMSS NICs continued to reference it.

Public IP quota

The initial Portal configuration attempted to create public IP configurations for VMSS instances.

This resulted in:

PublicIPCountLimitExceededByVMScaleSet


The architecture was corrected so that public connectivity is provided by the Load Balancer instead of individual VMSS instance public IPs.

Availability Zones

The VMSS successfully deployed instances across:

Zone 1
Zone 2


This provides the foundation for later availability and failure-testing exercises.

Current Architecture
                         INTERNET
                            |
                            v
                  Load Balancer Public IP
                            |
                            v
                    lb-commerce-web
                            |
                         bepool
                       /        \
                      /          \
                     v            v
              VMSS Instance 0   VMSS Instance 1
                 Zone 1            Zone 2
                     \              /
                      \            /
                       v          v
                         snet-web
                            |
                    nsg-commerce-web
                            |
                       vnet-commerce

Next Steps

Complete VMSS NSG reconciliation.

Verify both VMSS instances are healthy.

Test Load Balancer connectivity.

Test HTTP traffic to the web tier.

Create Application Gateway.

Integrate Application Gateway with the VMSS.

Add Azure Front Door.

Build application-tier VMSS.

Add Azure SQL and private endpoint.

Add Storage Account, Blob Storage and Azure Files.

Configure Azure Monitor and Log Analytics.

Configure alerts and backup.

Execute deliberate failure scenarios.



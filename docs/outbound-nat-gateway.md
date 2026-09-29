VMSS Load Balancer + NAT Gateway Milestone

Date: 2026-09-29

Completed

The Azure Commerce Platform web tier is now operational using an Azure Virtual Machine Scale Set behind an Azure Standard Load Balancer.

Architecture

Azure Virtual Network: vnet-commerce

Web subnet: snet-web

Web subnet CIDR: 172.16.1.0/24

VM Scale Set: vmss-skabiral

VMSS instances: 0 and 1

Web NSG: nsg-commerce-web

Load Balancer: lb-commerce-web

Load Balancer public IP: 48.216.169.199

NAT Gateway: nat-commerce

NAT Gateway public IP: 74.235.237.166

Web Tier

Both VMSS instances are running Nginx on TCP port 80.

Instance 0:

vmss-skab000000


Instance 1:

vmss-skab000001


Local validation on both instances returned:

HTTP/1.1 200 OK
Server: nginx/1.24.0 (Ubuntu)


Nginx is listening on:

0.0.0.0:80
[::]:80

NAT Gateway

Initially, the VMSS instances could resolve azure.archive.ubuntu.com but could not establish an outbound TCP connection to port 80.

After attaching the NAT Gateway to snet-web, outbound connectivity was restored.

apt-get update successfully downloaded approximately 37 MB of Ubuntu package metadata from:

http://azure.archive.ubuntu.com/ubuntu


Both VMSS instances successfully installed Nginx after NAT Gateway configuration.

Load Balancer Validation

The public Load Balancer endpoint:

http://48.216.169.199/


returns HTTP 200.

Repeated requests produced responses from both VMSS instances:

VMSS Instance: 0
Hostname: vmss-skab000000


and:

VMSS Instance: 1
Hostname: vmss-skab000001


This confirms that the Azure Load Balancer is distributing HTTP traffic across the VMSS backend instances.

Network Security

The web NSG currently allows:

Rule	Direction	Source	Destination	Port
Allow-HTTP	Inbound	Internet	Web subnet	TCP/80
Allow-HTTPS	Inbound	Internet	Web subnet	TCP/443
Allow-AzureLoadBalancer	Inbound	AzureLoadBalancer	Web subnet	Any

The application and data tiers have separate NSGs:

nsg-commerce-app allows TCP/8080 from 172.16.1.0/24

nsg-commerce-data allows TCP/1433 from 172.16.2.0/24

Important Design Distinction

The Load Balancer public IP and NAT Gateway public IP serve different purposes.

Load Balancer public IP

Used for:

Internet
   |
   v
Public Load Balancer
   |
   v
VMSS web instances


It provides the public inbound entry point for HTTP/HTTPS traffic.

NAT Gateway public IP

Used for:

VMSS web instances
   |
   v
NAT Gateway
   |
   v
Internet


It provides predictable outbound internet connectivity for resources in the subnet.

The NAT Gateway public IP is therefore not the public address used by users to reach the website.

Current Traffic Flow

Inbound:

Internet
    |
    v
48.216.169.199
    |
    v
Azure Load Balancer
    |
    +------------------+
    |                  |
    v                  v
VMSS Instance 0    VMSS Instance 1
172.16.1.x         172.16.1.x
    |                  |
    +--------+---------+
             |
           Nginx
           TCP/80


Outbound:

VMSS Instance
      |
      v
snet-web
      |
      v
NAT Gateway
      |
      v
74.235.237.166
      |
      v
Internet

Validation Commands

Check the NAT Gateway attached to the subnet:

az network vnet subnet show \
  -g "$RG" \
  --vnet-name "$VNET" \
  -n "$SUBNET" \
  --query '{
    addressPrefix:addressPrefix,
    natGateway:natGateway.id,
    networkSecurityGroup:networkSecurityGroup.id,
    routeTable:routeTable.id
  }' \
  -o json


Check Nginx on both VMSS instances:

for ID in 0 1; do
  az vmss run-command invoke \
    -g "$RG" \
    -n "$VMSS" \
    --instance-id "$ID" \
    --command-id RunShellScript \
    --scripts '
      systemctl status nginx --no-pager
      ss -lntp | grep ":80"
    '
done


Validate load balancing:

for i in {1..10}; do
  curl -s http://48.216.169.199/ |
    grep -E 'VMSS Instance|Hostname'
done

Result

The first functional web-tier milestone is complete:

Internet → Public Load Balancer → VMSS/Nginx

and outbound connectivity is provided separately through:

VMSS → NAT Gateway → Internet

The next phase is to connect the web tier to the application tier on TCP/8080 and subsequently connect the application tier to the database tier on TCP/1433.

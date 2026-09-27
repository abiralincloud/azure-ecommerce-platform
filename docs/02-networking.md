# E-Commerce Platform — Networking

## Overview

The e-commerce platform uses a dedicated Azure Virtual Network with separate subnets for the web, application, and data tiers.

The network is designed using a three-tier architecture to provide logical separation between public-facing workloads, backend services, and data services.

## Azure Region

`Central US`

## Resource Group

`rg-commerce-group`

## Virtual Network

| Property | Value |
|---|---|
| Name | `vnet-commerce` |
| Address Space | `172.16.0.0/16` |
| Region | Central US |

## Subnet Design

| Subnet | Address Range | Purpose |
|---|---|---|
| `snet-web` | `172.16.1.0/24` | Web/frontend workloads |
| `snet-app` | `172.16.2.0/24` | Backend/API workloads |
| `snet-data` | `172.16.3.0/24` | Data and private connectivity |

## Network Topology

```text
                         VNET
                    172.16.0.0/16
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
      WEB SUBNET       APP SUBNET       DATA SUBNET
    172.16.1.0/24    172.16.2.0/24    172.16.3.0/24
          |                |                |
          v                v                v
      NSG-WEB           NSG-APP           NSG-DATA


Network Security Groups
Each application tier has a dedicated Network Security Group.

NSG	Associated Subnet
nsg-commerce-web	snet-web
nsg-commerce-app	snet-app
nsg-commerce-data	snet-data


---------


Traffic Design
The intended application traffic flow is:


Internet
    |
    | HTTP / HTTPS
    v
Web Tier
172.16.1.0/24
    |
    | TCP 8080
    v
Application Tier
172.16.2.0/24
    |
    | TCP 1433
    v
Data Tier
172.16.3.0/24

------------


Web Tier
The web tier permits:

TCP 80 from the Internet

TCP 443 from the Internet

Application Tier
The application tier permits:

TCP 8080 from the web subnet

Source:

172.16.1.0/24

Destination:

172.16.2.0/24

Data Tier
The data tier permits:

TCP 1433 from the application subnet

Source:

172.16.2.0/24

Destination:

172.16.3.0/24

Security Model
The backend and data tiers are not intended to be directly accessible from the Internet.

The intended architecture is:


Internet
   |
   v
Web Tier
   |
   v
Application Tier
   |
   v
Data Tier

------------


Azure CLI
Create Resource Group
az group create \
  --name rg-commerce-group \
  --location centralus

Create Virtual Network
az network vnet create \
  --resource-group rg-commerce-group \
  --name vnet-commerce \
  --location centralus \
  --address-prefix 172.16.0.0/16

Create Web Subnet
az network vnet subnet create \
  --resource-group rg-commerce-group \
  --vnet-name vnet-commerce \
  --name snet-web \
  --address-prefix 172.16.1.0/24

Create Application Subnet
az network vnet subnet create \
  --resource-group rg-commerce-group \
  --vnet-name vnet-commerce \
  --name snet-app \
  --address-prefix 172.16.2.0/24

Create Data Subnet
az network vnet subnet create \
  --resource-group rg-commerce-group \
  --vnet-name vnet-commerce \
  --name snet-data \
  --address-prefix 172.16.3.0/24

Create Network Security Groups
az network nsg create \
  --resource-group rg-commerce-group \
  --name nsg-commerce-web \
  --location centralus

az network nsg create \
  --resource-group rg-commerce-group \
  --name nsg-commerce-app \
  --location centralus

az network nsg create \
  --resource-group rg-commerce-group \
  --name nsg-commerce-data \
  --location centralus

Associate NSGs With Subnets
az network vnet subnet update \
  --resource-group rg-commerce-group \
  --vnet-name vnet-commerce \
  --name snet-web \
  --network-security-group nsg-commerce-web

az network vnet subnet update \
  --resource-group rg-commerce-group \
  --vnet-name vnet-commerce \
  --name snet-app \
  --network-security-group nsg-commerce-app

az network vnet subnet update \
  --resource-group rg-commerce-group \
  --vnet-name vnet-commerce \
  --name snet-data \
  --network-security-group nsg-commerce-data

NSG Rules
Web — HTTP
az network nsg rule create \
  --resource-group rg-commerce-group \
  --nsg-name nsg-commerce-web \
  --name Allow-HTTP \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes Internet \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80

Web — HTTPS
az network nsg rule create \
  --resource-group rg-commerce-group \
  --nsg-name nsg-commerce-web \
  --name Allow-HTTPS \
  --priority 110 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes Internet \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 443

Web → Application
az network nsg rule create \
  --resource-group rg-commerce-group \
  --nsg-name nsg-commerce-app \
  --name Allow-Web-To-App \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 172.16.1.0/24 \
  --source-port-ranges '*' \
  --destination-address-prefixes 172.16.2.0/24 \
  --destination-port-ranges 8080

Application → Data
az network nsg rule create \
  --resource-group rg-commerce-group \
  --nsg-name nsg-commerce-data \
  --name Allow-App-To-SQL \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 172.16.2.0/24 \
  --source-port-ranges '*' \
  --destination-address-prefixes 172.16.3.0/24 \
  --destination-port-ranges 1433

Verification
The subnet configuration was verified using:

az network vnet subnet list \
  --resource-group rg-commerce-group \
  --vnet-name vnet-commerce \
  --output table

NSG associations were verified using:

az network vnet subnet list \
  --resource-group rg-commerce-group \
  --vnet-name vnet-commerce \
  --query "[].{Subnet:name,Prefix:addressPrefix,NSG:networkSecurityGroup.id}" \
  --output table

Design Notes
The network uses private RFC1918 address space and separates workloads by application tier.

The design will later be extended with:

Application Gateway

Load Balancer

Azure Front Door

Private Endpoints

Private DNS

VM Scale Sets

Azure SQL

Monitoring

-----------




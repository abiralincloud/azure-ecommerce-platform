# E-Commerce Platform — Foundation

## Project Overview

This project is a hands-on Azure infrastructure implementation for a fictional e-commerce company.

The environment is being built progressively to demonstrate practical Azure administration skills aligned with AZ-104 and real-world cloud operations.

The project covers networking, compute, storage, databases, security, monitoring, availability, backup, and troubleshooting.

## Azure Environment

| Property | Value |
|---|---|
| Azure Region | Central US |
| Resource Group | `rg-commerce-group` |
| Project | Azure E-Commerce Platform |

## Resource Group

The project uses a dedicated resource group:

`rg-commerce-group`

The resource group provides a logical management boundary for the resources associated with this project.

Eventually, the resource group will contain resources such as:

```text
rg-commerce-group
|
+-- vnet-commerce
|
+-- Network Security Groups
|
+-- VM Scale Sets
|
+-- Load Balancer
|
+-- Application Gateway
|
+-- Azure Front Door
|
+-- Storage Account
|
+-- Azure SQL
|
+-- Private Endpoints
|
+-- Monitoring resources


--------

Deployment Approach
The project uses two Azure administration methods:

Azure Portal
The Portal is used to understand:

Azure resource configuration

Resource dependencies

Network configuration

Security settings

Monitoring

Troubleshooting

Azure CLI
Azure CLI is used to:

Create resources

Configure resources

Query resource state

Verify deployments

Automate repeatable tasks

Project Methodology
Each major component follows this process:

Plan
  |
  v
Build
  |
  v
Verify
  |
  v
Document
  |
  v
Commit to Git
  |
  v
Troubleshoot

Naming Convention
The project uses a consistent naming approach.

Examples:

rg-commerce-group
vnet-commerce
snet-web
snet-app
snet-data
nsg-commerce-web
nsg-commerce-app
nsg-commerce-data


=------------------


Resource Management
Resources are organized into a single project resource group to make the environment easier to manage and remove after testing.

Before deploying potentially chargeable Azure services, the project's cost implications will be considered.

Current Status
Completed
 Resource group

 Virtual network

 Subnet architecture

 Network Security Groups

 Initial network security rules

 GitHub repository

 Project documentation structure

Next
 Web VM Scale Set

 Availability Zones

 Load Balancer

 Application Gateway

 Backend/API tier

 Azure SQL

 Private Endpoint

 Storage

 Azure Front Door

 Monitoring

 Alerts

 Backup

 Failure scenarios

 Troubleshooting documentation

----




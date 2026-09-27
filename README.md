# Azure E-Commerce Platform

## Project Overview

This project is a hands-on Azure infrastructure implementation for a fictional e-commerce company.

The goal is to design, deploy, secure, monitor, and troubleshoot a production-style Azure environment while developing practical skills aligned with the AZ-104 Azure Administrator certification.

## Scenario

The company operates an online retail platform consisting of:

- Public web application
- Backend/API services
- Relational database
- Application storage
- Highly available compute
- Network security
- Monitoring and alerting
- Backup and disaster recovery

## Azure Region

Central US

## Resource Group

`rg-commerce-group`

## Current Architecture

```text
Internet
   |
Azure Front Door
   |
Application Gateway
   |
Load Balancer
   |
Web Tier
   |
Application/API Tier
   |
Private Endpoint
   |
Azure SQL



------------



Network Architecture

VNet
172.16.0.0/16
|
+-- Web Subnet
|   172.16.1.0/24
|
+-- App Subnet
|   172.16.2.0/24
|
+-- Data Subnet
    172.16.3.0/24
Current Progress
Completed
Resource Group

Virtual Network

Web subnet

Application subnet

Data subnet

Web Network Security Group

Application Network Security Group

Data Network Security Group

Initial network security rules

Planned
Virtual Machine Scale Sets

Availability Zones

Azure Load Balancer

Application Gateway

Azure Front Door

Azure SQL

Private Endpoints

Storage Accounts

Blob Storage

Azure Files

Azure Monitor

Log Analytics

Alerts

Backup

RBAC

DNS

Troubleshooting scenarios

Learning Approach
Each major Azure component will be implemented and documented using:

Azure Portal

Azure CLI

The environment will then be deliberately tested and broken to practice troubleshooting.

Project Goals
The project is intended to demonstrate practical knowledge of:

Azure networking

Compute

Storage

Identity and access

Security

Monitoring

High availability

Disaster recovery

Azure administration

Troubleshooting

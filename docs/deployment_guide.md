# Deployment Guide

## Prerequisites

- Azure subscription (dedicated recommended)
- Terraform >= 1.5
- `Contributor` role on subscription

## Step-by-Step

```bash
az login
az account set --subscription "Honeynet-Demo"

cd terraform
terraform init
terraform plan -var="environment=demo"
terraform apply
```

## Verification

1. Check Azure Portal → Resource Groups → `honeynet-rg`
2. Verify VM `PROD-DB-01` exists with public IP
3. Verify Key Vault has secret `prod-db-password`
4. Verify Storage Account has container `customer-data`

## Sentinel Onboarding

Import the JSON rule files from `detection/sentinel_rules/` into your Sentinel workspace.

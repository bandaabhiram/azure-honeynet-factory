# Azure Canary Token Factory & Honeynet

> **The only alert you can trust is one that shouldn't exist.**

A Terraform module factory that deploys realistic Azure honeypots — fake VMs named `PROD-DB-01` with fake SQL connections, Key Vaults with "secrets" like `prod-db-password`, Storage Accounts with "customer-data" blobs — all instrumented with high-fidelity alerting to Sentinel. Includes a "breach simulation" mode that safely mimics attacker TTPs to test your detection pipeline.

## 🎓 Author Credentials
- **AZ-500** Microsoft Certified: Azure Security Engineer Associate
- **MSc Cybersecurity** — Heriot-Watt University (NCSC-certified)
- **1 Year Azure DevOps** — CI/CD, IaC, container security

## 🚨 Problem Statement

Traditional IDS/IPS generates 10,000 alerts/day. 99% are false positives. Security teams develop "alert fatigue" and miss real breaches.

**Honeypots generate zero false positives** because no legitimate traffic should ever touch them. Any interaction is a confirmed threat.

## 🏗️ Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Terraform      │────▶│  Isolated VNet  │────▶│  Honeypots      │
│  Module Factory │     │  (no outbound)  │     │  (VM, KV, SQL)  │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                              ┌─────────────────────────┘
                              ▼
                    ┌─────────────────┐
                    │  Azure Sentinel │
                    │  (KQL rules)    │
                    │  ANY touch = P1 │
                    └─────────────────┘
```

## 🛠️ Technologies & Rationale

| Technology | Why |
|------------|-----|
| **Terraform Modules** | `module "sql_honeypot" { environment = "prod" }` deploys a complete decoy |
| **Azure Sentinel + KQL** | Zero false positives — tuned to honeypot-only data sources |
| **Azure Functions (C#)** | Bait interaction generators — fake login attempts, file access |
| **Azure Private Link + Isolated VNet** | Honeypots look accessible but are completely isolated |
| **Azure Bastion + JIT** | Even *your* access is monitored and time-bound |
| **Azure DevOps Pipelines** | Auto-deploy honeypots to new regions |

## ⚖️ Tradeoffs Made

- **Realism vs Risk:** Dedicated subscriptions, NSG deny-all outbound, Azure Firewall inspection
- **Cost vs Coverage:** ~$50/month per honeypot. 5 types × 3 regions = $750/month. One breach detection saves $4.2M (IBM avg).
- **Attribution vs Legal:** Synthetic data from Faker library — realistic schema, zero real PII.

## 🚀 Quick Start

```bash
git clone https://github.com/bandaabhiram/azure-honeynet-factory.git
cd azure-honeynet-factory/terraform
terraform init
terraform apply -var="environment=demo"
```

## 📁 Repo Structure

```
azure-honeynet-factory/
├── terraform/modules/
│   ├── vm_honeypot/
│   ├── keyvault_honeypot/
│   ├── storage_honeypot/
│   ├── sql_honeypot/
│   └── aks_honeypot/
├── bait_generator/
├── detection/sentinel_rules/
├── simulation/safe_attacker/
└── docs/
```

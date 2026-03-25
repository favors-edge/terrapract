# Azure Hub-and-Spoke Network Architecture
### Infrastructure as Code with Terraform

This project deploys a production-style hub-and-spoke network topology on Microsoft Azure using Terraform. It is part of a personal lab series built to develop & hone hands-on skills towards Azure IaC Administration.

---

## Architecture Overview

```
                        ┌─────────────────────┐
                        │    vnet-hub-dev      │
                        │    10.0.0.0/16       │
                        │   (central routing)  │
                        └──────────┬──────────┘
               ┌──────────────────┼──────────────────┐
               │                  │                  │
    ┌──────────▼────────┐ ┌───────▼────────┐ ┌──────▼──────────────┐
    │  vnet-spoke-web   │ │ vnet-spoke-app │ │ vnet-spoke-storage  │
    │  10.1.0.0/16      │ │ 10.2.0.0/16    │ │ 10.3.0.0/16         │
    │                   │ │                │ │                     │
    │  ├─ Linux VM       │ │  ├─ (reserved) │ │  ├─ Storage Account │
    │  └─ NSG            │ │               │ │  └─ Private Endpoint │
    └───────────────────┘ └────────────────┘ └─────────────────────┘
```

Traffic between spokes routes through the hub. Spokes have no direct connectivity to each other, mirroring enterprise network segmentation patterns.

---

## What Gets Deployed

| Resource | Name | Purpose |
|---|---|---|
| Resource Group | `rg-hubspoke-dev` | Container for all resources |
| Hub VNet | `vnet-hub-dev` | Central routing point |
| Spoke VNet | `vnet-spoke-web-dev` | Web workload network |
| Spoke VNet | `vnet-spoke-app-dev` | App workload network (reserved) |
| Spoke VNet | `vnet-spoke-storage-dev` | Storage workload network |
| VNet Peerings | 3 pairs (6 total) | Bidirectional hub-to-spoke connectivity |
| Linux VM | `vm-web` | Test workload (Ubuntu 22.04, Standard_B1s) |
| NSG | `nsg-web` | Subnet-level traffic control on web spoke |
| Storage Account | `sthubspoke<random>` | Blob storage with public access disabled |
| Private Endpoint | `pe-storage` | Private network access to blob storage |

---

## Security Highlights

**Network Security Group** — Applied at the subnet level on the web spoke. Default deny-all inbound posture. Rules can be added to allow specific ports from specific sources only.

**Private Endpoint** — The storage account has `public_network_access_enabled = false`. It is only reachable from within the VNet via its private IP address, not from the public internet.

**No public VM IP** — The web VM has no public IP address assigned. It is only accessible from within the VNet.

**Sensitive variables** — The VM admin password is declared as `sensitive = true` in Terraform and passed via a local `terraform.tfvars` file that is excluded from version control via `.gitignore`.

---

## Project Structure

```
hub-spoke-azure/
├── provider.tf       # AzureRM + random provider config, version pinning
├── variables.tf      # Input variables with types and descriptions
├── main.tf           # All resource definitions
├── outputs.tf        # Key values printed after deployment
├── .gitignore        # Excludes state files, tfvars, and .terraform/
└── README.md
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- An active Azure subscription

---

## How to Deploy

```bash
# 1. Authenticate to Azure
az login

# 2. Clone the repo and navigate into it
git clone https://github.com/YOUR_USERNAME/hub-spoke-azure.git
cd hub-spoke-azure

# 3. Create a tfvars file with your credentials (this file is gitignored)
cat > terraform.tfvars <<EOF
admin_password = "YourSecurePassword1!"
EOF

# 4. Initialize Terraform (downloads provider plugins)
terraform init

# 5. Preview the deployment plan
terraform plan -out=tfplan

# 6. Apply the plan
terraform apply tfplan
```

After deployment, Terraform will print the storage account name and the VM's private IP address as outputs.

---

## Cost Management

This lab is designed to stay within Azure free tier limits where possible. I really didn't want to run up an insane bill just to get hands on practice. The only billable resource when running is the VM.

| Resource | Estimated cost |
|---|---|
| Standard_B1s VM (running) | ~$8/month |
| Standard_B1s VM (deallocated) | $0 compute |
| Storage Account LRS (empty) | < $0.01/month |
| VNets, peerings, NSG | Free |

**Deallocate the VM when not in use:**
```bash
az vm deallocate --name vm-web --resource-group rg-hubspoke-dev
```

**Destroy all resources when done with the lab:**
```bash
terraform destroy
```

---

## Tools & Technologies

![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?logo=terraform)
![Azure](https://img.shields.io/badge/Microsoft_Azure-0089D6?logo=microsoft-azure)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04_LTS-E95420?logo=ubuntu)

- **Terraform** — Infrastructure provisioning and state management
- **AzureRM Provider** — Azure resource management via Terraform
- **Azure Virtual Networks** — Hub-and-spoke topology with VNet peering
- **Azure Private Endpoints** — Private connectivity to PaaS services
- **Network Security Groups** — Subnet-level traffic filtering
- **Azure Storage** — Blob storage with private-only access

---

## What I Learned

> *(When starting this project, I understood that IaC was a great way to get infrastructure up and running quickly. Even more so it can be leveraged by scaling once you have a baseline for what a team is looking for. What surprised me while working on this project is how well Terraform can figure out all the small details on its own and point out anything that may not work. Understanding exactly how to not hardcode credentials is something I made a point to do because it is best practice and handy to ensure that I can continue to crank out projects & showcase them without worry of bad actors. I'm excited to understand more about automation tool and IaC. This project has prompted me to think about the hierarchical structure of objects that live inside Azure and how everything builds upon one another to create a cohesive environment. Being that human error can at times be unavoidable, my next project will focus on landing Zones. Landing Zones are the foundational frameworks that infrastructure can be built upon to ensure user error is mitigated and a team can go in headfirst to provide solutions to clients for their workload needs.)*

---

## Roadmap - Future Additions

- [ ] Add Azure Key Vault integration for secret management
- [ ] Deploy Azure Firewall in the hub for centralized traffic inspection
- [ ] Add a Bastion host for secure VM access without a public IP
- [ ] Introduce a second environment (staging) using Terraform workspaces

---

## Author

Built by **[Peter Inneh]** as part of a self-directed Azure Infrastructure Administration lab series.

[LinkedIn](www.linkedin.com/in/peter-inneh) · [GitHub](https://github.com/favors-edge)

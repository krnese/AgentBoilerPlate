# Azure Load Balancer with 2 VMs - Test Environment

This project deploys a cost-optimized, zone-redundant Azure infrastructure with 2 Linux VMs behind a Standard Load Balancer in Sweden Central region.

## 🌐 Live Deployment

**Status**: ✅ **DEPLOYED & OPERATIONAL**

| Resource | Value |
|----------|-------|
| **Public IP** | `4.223.161.55` |
| **Endpoint** | http://4.223.161.55 |
| **Resource Group** | `rg-lbvm-test-swedencentral` |
| **Region** | Sweden Central |
| **Availability** | 99.99% SLA (zone-redundant) |

### Quick Test
```bash
# Test the live endpoint
curl http://4.223.161.55

# Test load distribution across VMs
for i in {1..10}; do curl -s http://4.223.161.55 | grep -oP '(?<=<strong>Hostname:</strong> )[^<]+'; done
```

## 📋 Overview

### Architecture
- **2 Linux VMs** (Ubuntu 22.04 LTS, Standard_B2ats_v2)
  - `vm-lbvm-test-01` (Zone 1)
  - `vm-lbvm-test-02` (Zone 2)
- **Standard Load Balancer** (`lb-lbvm-test`) - zone-redundant, public-facing
- **Public IP** (`pip-lbvm-test`) - 4.223.161.55 (Standard SKU, zone-redundant)
- **Virtual Network** (10.0.0.0/16) with dedicated subnet (10.0.1.0/24)
- **Network Security Group** (`nsg-lbvm-vms`) with restrictive inbound rules
- **Health Probe** on TCP port 80
- **Availability Zones**: Zone 1 and Zone 2 for 99.99% SLA

### Architecture Diagram
```
Internet
    |
    v
[Public IP: 4.223.161.55]
    |
    v
[Load Balancer: lb-lbvm-test]
    |
    +-- Backend Pool
        |
        +-- vm-lbvm-test-01 (Zone 1)
        |   Private IP: 10.0.1.4
        |   Ubuntu 22.04 + Nginx
        |
        +-- vm-lbvm-test-02 (Zone 2)
            Private IP: 10.0.1.5
            Ubuntu 22.04 + Nginx
```

### Cost Breakdown
Estimated monthly cost: **~$40-45** (pay-as-you-go pricing in Sweden Central)

| Resource | SKU/Type | Quantity | Est. Monthly Cost |
|----------|----------|----------|-------------------|
| Virtual Machines | Standard_B2ats_v2 | 2 | ~$30 |
| OS Disks | Standard SSD (30GB) | 2 | ~$5 |
| Standard Load Balancer | Standard | 1 | ~$5 |
| Public IP | Standard | 1 | ~$4 |
| **Total** | | | **~$44** |

*Note: Actual costs may vary based on usage patterns, data transfer, and burstable CPU credit consumption.*

## 🚀 Quick Start

### Prerequisites

1. **Azure CLI** (version 2.50.0 or later)
   ```bash
   az --version
   ```
   Install from: https://aka.ms/azure-cli

2. **Azure Subscription** with Contributor access
   ```bash
   az login
   az account show
   ```

3. **SSH Key Pair** (for VM authentication)
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

### Deployment Approach

This deployment uses **subscription-level deployment** with Bicep. Key features:
- `targetScope='subscription'` in main.bicep
- Resource group is created as part of the deployment
- Single command deployment from subscription level

### Deployment

#### Option 1: Quick Deploy with Default SSH Key

```bash
cd workloads/lb-vm-test

# Make script executable
chmod +x deploy.sh

# Deploy infrastructure (uses ~/.ssh/id_rsa.pub by default)
./deploy.sh
```

#### Option 2: Deploy with Custom SSH Key

```bash
# Set your SSH public key
export SSH_PUBLIC_KEY=$(cat /path/to/your/key.pub)

# Deploy infrastructure
./deploy.sh
```

#### Option 3: Manual Subscription-Level Deployment

```bash
# Deploy at subscription level (creates resource group automatically)
az deployment sub create \
  --name lb-vm-deployment-$(date +%s) \
  --location swedencentral \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.bicepparam \
  --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)"
```

**Deployment Time**: ~5-7 minutes

### Post-Deployment Configuration

The VMs are automatically configured via cloud-init during deployment. If you need to reconfigure:

```bash
./scripts/configure-vms.sh
```

This script:
- Installs Nginx web server on both VMs
- Creates custom HTML pages with hostname identification
- Verifies health probe endpoint on port 80

### Validation and Testing

#### Automated Testing
```bash
./scripts/test-deployment.sh
```

This script:
- Tests Load Balancer public IP endpoint (4.223.161.55)
- Verifies traffic distribution across both VMs (10 requests)
- Checks health probe status
- Displays VM status and zone assignment

#### Manual Testing

```bash
# Test the live endpoint
curl http://4.223.161.55

# Test traffic distribution (should alternate between vm-01 and vm-02)
for i in {1..10}; do 
  curl -s http://4.223.161.55 | grep -oP '(?<=<strong>Hostname:</strong> )[^<]+'; 
done

# Get detailed load balancer info
az network lb show \
  --resource-group rg-lbvm-test-swedencentral \
  --name lb-lbvm-test \
  --output table

# Check VM health status in backend pool
az network nic list \
  -g rg-lbvm-test-swedencentral \
  --query "[].{NIC:name, VM:virtualMachine.id, BackendPools:ipConfigurations[0].loadBalancerBackendAddressPools}" \
  -o json
```

#### Expected Results
- ✅ HTTP 200 response from http://4.223.161.55
- ✅ Traffic alternates between `vm-lbvm-test-01` and `vm-lbvm-test-02`
- ✅ Both VMs show "Running" state
- ✅ Health probe shows "Healthy" status
- ✅ Both NICs connected to backend pool

## 📁 Project Structure

```
lb-vm-test/
├── README.md                      # This file
├── plan.md                        # Architectural design document
├── deploy.sh                      # Main deployment script
├── infra/
│   ├── main.bicep                 # Main orchestration template
│   ├── main.bicepparam            # Parameter file with defaults
│   ├── network.bicep              # VNet, Subnet, NSG
│   ├── loadbalancer.bicep         # Public IP, Load Balancer, rules
│   └── vm.bicep                   # VMs, NICs, OS disks
└── scripts/
    ├── configure-vms.sh           # Post-deployment VM configuration
    └── test-deployment.sh         # Validation and testing script
```

## 🔧 Configuration

### Default Parameters (in `main.bicepparam`)

| Parameter | Default Value | Description |
|-----------|---------------|-------------|
| `location` | `swedencentral` | Azure region |
| `environment` | `test` | Environment identifier |
| `vmSku` | `Standard_B2ats_v2` | VM size (Basv2-series AMD) |
| `vmCount` | `2` | Number of VMs |
| `adminUsername` | `azureuser` | VM admin username |
| `vnetAddressPrefix` | `10.0.0.0/16` | VNet address space |
| `subnetAddressPrefix` | `10.0.1.0/24` | Subnet address space |
| `availabilityZones` | `['1', '2']` | Availability zones for VMs |

### Customization

To override parameters during deployment:

```bash
az deployment group create \
  --name lb-vm-deployment \
  --resource-group rg-lbvm-test-swedencentral \
  --template-file ./infra/main.bicep \
  --parameters ./infra/main.bicepparam \
  --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
  --parameters vmCount=3 \
  --parameters vmSku=Standard_B1s
```

## 🛡️ Security

### Network Security Group Rules

| Priority | Rule | Source | Destination | Port | Action |
|----------|------|--------|-------------|------|--------|
| 100 | AllowHTTPInbound | Internet | Subnet | 80 | Allow |
| 110 | AllowAzureLoadBalancerInbound | AzureLoadBalancer | * | * | Allow |
| 4096 | DenyAllInbound | * | * | * | Deny |

### Best Practices Implemented

✅ **Zone Redundancy**: Public IP and Load Balancer are zone-redundant  
✅ **No Public IPs on VMs**: VMs use private IPs only; access via Load Balancer  
✅ **SSH Key Authentication**: Password authentication disabled  
✅ **NSG at Subnet Level**: Centralized security management  
✅ **Health Probe Allowed**: Azure Load Balancer probe IP (168.63.129.16) permitted  
✅ **TCP Reset Enabled**: Graceful idle timeout handling  
✅ **Explicit Outbound Rule**: Manual SNAT port allocation (1024 ports per instance)  
✅ **Standard SKU**: Best practices (Basic Load Balancer retired Sept 2025)  

## 📊 Monitoring and Operations

### View Resources in Azure Portal

```bash
# Get resource group URL
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/rg-lbvm-test-swedencentral"
```

### Check VM Status

```bash
az vm list \
  --resource-group rg-lbvm-test-swedencentral \
  --show-details \
  --output table
```

### View Load Balancer Metrics

```bash
az monitor metrics list \
  --resource $(az network lb show -g rg-lbvm-test-swedencentral -n lb-lbvm-test --query id -o tsv) \
  --metric "VipAvailability" \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ)
```

### SSH into VMs (via Azure Bastion or Jump Box)

```bash
# VMs don't have public IPs by default
# Option 1: Use Azure Bastion (deploy separately)
# Option 2: Add temporary NSG rule for your IP
# Option 3: Use Azure CLI SSH (requires VM extension)

az ssh vm \
  --resource-group rg-lbvm-test-swedencentral \
  --name vm-lbvm-test-01
```

## 🧹 Cleanup

### Remove All Resources

To delete all resources and stop incurring charges:

```bash
# Delete the resource group (removes all contained resources)
az group delete \
  --name rg-lbvm-test-swedencentral \
  --yes \
  --no-wait

# Verify deletion (optional - wait for completion)
az group exists --name rg-lbvm-test-swedencentral
```

**Cleanup Time**: ~3-5 minutes

### What Gets Deleted
The resource group deletion removes:
- ✅ 2 Virtual Machines (vm-lbvm-test-01, vm-lbvm-test-02)
- ✅ 2 Network Interfaces with configurations
- ✅ 2 OS Disks (Standard SSD)
- ✅ Standard Load Balancer (lb-lbvm-test)
- ✅ Public IP Address (4.223.161.55)
- ✅ Virtual Network and Subnet
- ✅ Network Security Group (nsg-lbvm-vms)
- ✅ All diagnostic settings and configurations

### Cost Impact
After deletion, you will **stop being charged** for:
- VM compute hours (~$0.041/hour x 2 VMs)
- Storage (OS disks)
- Load Balancer hourly rate
- Public IP address

**Note**: SSH keys on your local machine are NOT deleted. You can reuse them for future deployments.

## 🐛 Troubleshooting

### Issue: Load Balancer not responding (HTTP 000 or timeout)

**Solution:**
1. Wait 2-3 minutes for cloud-init to complete VM initialization
2. Check NSG allows port 80 from Internet:
   ```bash
   az network nsg rule list -g rg-lbvm-test-swedencentral --nsg-name nsg-lbvm-vms -o table
   ```
3. Verify VMs are running:
   ```bash
   az vm list -g rg-lbvm-test-swedencentral --show-details -o table
   ```
4. Reconfigure VMs manually:
   ```bash
   ./scripts/configure-vms.sh
   ```

### Issue: Health probe shows unhealthy status

**Solution:**
1. Check if port 80 is open on VMs:
   ```bash
   az vm run-command invoke \
     -g rg-lbvm-test-swedencentral \
     -n vm-lbvm-test-01 \
     --command-id RunShellScript \
     --scripts "ss -tuln | grep :80"
   ```
2. Verify NSG allows Azure Load Balancer probe (168.63.129.16):
   ```bash
   az network nsg rule show \
     -g rg-lbvm-test-swedencentral \
     --nsg-name nsg-lbvm-vms \
     -n AllowAzureLoadBalancerInbound
   ```

### Issue: Traffic only goes to 1 VM

**Possible Causes:**
- One VM is unhealthy (check health probe status)
- One VM's Nginx is not running
- Session persistence enabled (default is 5-tuple hash, no persistence)

**Solution:**
1. Check both VMs' health:
   ```bash
   ./scripts/test-deployment.sh
   ```
2. Restart Nginx on both VMs:
   ```bash
   ./scripts/configure-vms.sh
   ```

### Issue: Deployment fails with "SSH public key required"

**Solution:**
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Deploy with explicit key
export SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
./deploy.sh
```

### Issue: VM SKU not available in region

**Solution:**
Change VM SKU in `main.bicepparam`:
```bicep
param vmSku = 'Standard_B1s'  // Fallback option
```

## 📚 References

- [Azure Load Balancer Best Practices](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-best-practices)
- [Basv2-series VM Specifications](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/basv2-series)
- [Standard Load Balancer Overview](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview)
- [Zone Redundancy in Azure](https://learn.microsoft.com/en-us/azure/reliability/migrate-load-balancer)
- [Bicep Language Documentation](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

## 📝 Notes

- **Cost Optimization**: This setup uses the cheapest viable VM SKU (Basv2-series) and Standard SSD for test environments
- **No NAT Gateway**: Outbound connectivity uses Load Balancer outbound rules (saves ~$30/month)
- **Cloud-Init**: VMs are configured automatically during deployment using cloud-init (no manual setup required)
- **Zone Redundancy**: VMs are distributed across Zone 1 and Zone 2 for 99.99% SLA
- **Basic LB Retirement**: Standard Load Balancer is used (Basic LB retired September 2025)
- **Subscription-Level Deployment**: Uses `targetScope='subscription'` for automated resource group creation
- **Nginx Auto-Install**: Web server is automatically installed and configured via cloud-init during VM provisioning

## 🎯 Production Considerations

If adapting this for production use, consider:

### Enhancements
- [ ] Add **Azure Bastion** for secure SSH access (~$150/month)
- [ ] Implement **Azure Monitor** alerts for health probe failures
- [ ] Add **Application Gateway** with WAF for enhanced security (~$250/month)
- [ ] Deploy **Azure Key Vault** for SSH key and secret management
- [ ] Enable **Azure Backup** for VM state preservation
- [ ] Implement **Azure DDoS Protection** on the virtual network (~$2,944/month)

### Scaling
- [ ] Increase VM SKU to **Standard_D2s_v5** for consistent performance (~$140/month for 2 VMs)
- [ ] Add more VMs to backend pool (up to 1,000 instances supported)
- [ ] Implement **VM Scale Sets** for auto-scaling based on metrics

### Security
- [ ] Restrict NSG source to specific IP ranges (instead of Internet)
- [ ] Enable **Azure Policy** compliance monitoring
- [ ] Implement **Just-In-Time (JIT) VM access** via Microsoft Defender for Cloud
- [ ] Add TLS/SSL termination at Load Balancer level

### Monitoring
- [ ] Configure **Azure Monitor** with Log Analytics workspace
- [ ] Set up **Application Insights** for application-level monitoring
- [ ] Create **Azure Dashboard** for operational visibility
- [ ] Enable **Network Watcher** for traffic analysis

## 📄 License

This project is part of the AgentBoilerPlate repository. See the repository LICENSE file for details.

---

**Deployment Status**: ✅ **LIVE & OPERATIONAL**  
**Public Endpoint**: http://4.223.161.55  
**Created**: January 23, 2026  
**Environment**: Test  
**Region**: Sweden Central  
**Resource Group**: rg-lbvm-test-swedencentral  
**Estimated Cost**: $40-45/month  
**SLA**: 99.99% (zone-redundant)  
**Deployment Model**: Subscription-level Bicep with automated resource group creation

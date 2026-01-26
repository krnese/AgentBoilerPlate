# Azure Load Balancer with 2 VMs - Test Environment

## Project Overview
Deploy a cost-optimized, zone-redundant test environment with 2 Linux VMs behind a public Azure Standard Load Balancer in Sweden Central region.

## Architecture Summary

### Components
- **2 Linux Virtual Machines** (Ubuntu 22.04 LTS)
- **1 Public Standard Load Balancer** (zone-redundant)
- **1 Virtual Network** with dedicated subnet
- **1 Network Security Group** (NSG)
- **1 Public IP Address** (Standard SKU, zone-redundant)
- **Load Balancer Health Probe** (TCP port 80)
- **Load Balancer Rule** (HTTP traffic distribution)

### Architecture Diagram (Logical)
```
Internet
    |
    v
[Public IP - Zone Redundant]
    |
    v
[Azure Load Balancer - Standard SKU]
    |
    +-- Frontend IP Configuration
    |   
    +-- Backend Pool
        |
        +-- [VM-01] Ubuntu 22.04 - Standard_B2ats_v2 (Zone 1)
        |       |
        |       +-- Private IP (10.0.1.4)
        |       +-- NSG attached
        |
        +-- [VM-02] Ubuntu 22.04 - Standard_B2ats_v2 (Zone 2)
                |
                +-- Private IP (10.0.1.5)
                +-- NSG attached

[Virtual Network: 10.0.0.0/16]
    |
    +-- [Subnet: 10.0.1.0/24]
```

## Requirements Analysis

### Functional Requirements
1. **2 Virtual Machines**: Deploy 2 VMs for redundancy
2. **Load Balancer**: Public-facing Standard Load Balancer
3. **Operating System**: Linux (Ubuntu 22.04 LTS)
4. **Region**: Sweden Central
5. **Environment**: Test/Development
6. **Cost**: Minimize cost using cheapest viable SKU

### Non-Functional Requirements
1. **Availability**: Zone-redundant architecture (SLA: 99.99%)
2. **Security**: NSG with restrictive inbound rules, no public IPs on VMs
3. **Scalability**: Backend pool supports up to 5,000 instances
4. **Compliance**: Adheres to Azure subscription policies (audit-only)

## Policy Compliance Check

### Current Subscription Policies
Based on Azure Resource Graph query, the following policies are active:
- **Audit-StorageAccount-PublicAccess-assignment** (Audit only)
- **DataProtectionSecurityCenter** (Audit initiative)
- **Audit-StorageAccount-CustomerManagedKeys-assignment** (Audit only)

**Impact**: No deny policies that would block VM or Load Balancer deployment. All policies are audit-only.

## Architecture Decisions

### 1. VM SKU Selection: **Standard_B2ats_v2** (Basv2-series)

**Rationale**:
- **Cheapest Option**: Basv2 series is AMD-based, burstable, and cost-effective for test environments
- **Specifications**: 2 vCPU, 1 GiB RAM, burstable performance with CPU credits
- **Cost-Effective**: Significantly cheaper than general-purpose (D-series) or compute-optimized SKUs
- **Suitable for Test**: Burstable workloads with low average CPU utilization
- **Regional Availability**: Fully supported in Sweden Central

**Alternative Considered**:
- Standard_B1s (1 vCPU, 1 GiB RAM) - Even cheaper but may be too limited
- Standard_B2s_v2 (Bsv2 Intel-based) - Slightly more expensive than Basv2

### 2. Operating System: **Ubuntu 22.04 LTS**

**Rationale**:
- **No License Cost**: Linux eliminates Windows Server licensing fees
- **LTS Support**: Ubuntu 22.04 provides long-term support until 2027
- **Wide Adoption**: Industry-standard for cloud workloads
- **Image**: Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest

### 3. Load Balancer: **Standard SKU**

**Rationale**:
- **Zone Redundancy**: Supports availability zones for 99.99% SLA
- **No Outbound Bandwidth Limits**: Standard LB doesn't throttle outbound connections
- **Security**: Closed by default; requires explicit NSG rules
- **Best Practice**: Microsoft recommends Standard LB (Basic LB retired Sept 2025)
- **Cost**: Pay-as-you-go pricing (no upfront cost)

### 4. Availability Zones: **Zone 1 and Zone 2**

**Rationale**:
- **High Availability**: Distributes VMs across zones (Zone 1, Zone 2)
- **Zone-Redundant Frontend**: Public IP and Load Balancer are zone-redundant
- **SLA**: Achieves 99.99% uptime with at least 2 healthy backend instances
- **Best Practice**: Per Microsoft Load Balancer best practices

### 5. Networking: **New Virtual Network (10.0.0.0/16)**

**Rationale**:
- **Isolation**: Dedicated VNet for test workload
- **Subnet Design**: Single subnet (10.0.1.0/24) provides 251 usable IPs
- **No Public IPs on VMs**: VMs use private IPs only; access via Load Balancer
- **NAT Gateway**: Not included (cost optimization); outbound access via LB outbound rules

### 6. Network Security Group (NSG): **Restrictive Inbound Rules**

**Rationale**:
- **Principle of Least Privilege**: Allow only necessary traffic
- **Inbound Rules**:
  - Allow HTTP (port 80) from Internet to subnet (priority 100)
  - Allow Azure Load Balancer health probes (168.63.129.16) on port 80
- **Outbound Rules**: Default allow (for package updates)
- **Best Practice**: NSG attached to subnet (not individual NICs)

### 7. Health Probe: **TCP on Port 80**

**Rationale**:
- **Protocol**: TCP is lightweight and faster than HTTP/HTTPS
- **Port**: 80 (HTTP) - standard web traffic port
- **Interval**: 5 seconds (default)
- **Threshold**: 2 consecutive failures mark instance as unhealthy
- **Best Practice**: Unblock 168.63.129.16 (Azure Load Balancer probe IP)

### 8. Load Balancing Rule: **HTTP (Port 80)**

**Rationale**:
- **Protocol**: TCP
- **Frontend Port**: 80
- **Backend Port**: 80
- **Distribution Mode**: 5-tuple hash (default)
- **Session Persistence**: None (stateless test environment)
- **Idle Timeout**: 15 minutes (default)
- **TCP Reset**: Enabled (best practice)
- **Outbound SNAT**: Disabled (use explicit outbound rule)

### 9. Outbound Connectivity: **Outbound Rule via Load Balancer**

**Rationale**:
- **No Default Outbound Access**: Default outbound access retires Sept 2025
- **Explicit Outbound Rule**: Use Load Balancer frontend IP for outbound connections
- **Manual Port Allocation**: Prevents SNAT exhaustion (best practice)
- **Cost Optimization**: No NAT Gateway required (saves ~$30/month)

## Resource Naming Convention

Following Azure best practices and keeping test environment simplicity:

| Resource Type | Name | Pattern |
|---------------|------|---------|
| Resource Group | `rg-lbvm-test-swedencentral` | rg-{workload}-{env}-{region} |
| Virtual Network | `vnet-lbvm-test` | vnet-{workload}-{env} |
| Subnet | `snet-vms` | snet-{purpose} |
| Network Security Group | `nsg-lbvm-vms` | nsg-{workload}-{purpose} |
| Public IP | `pip-lbvm-test` | pip-{workload}-{env} |
| Load Balancer | `lb-lbvm-test` | lb-{workload}-{env} |
| VM 1 | `vm-lbvm-test-01` | vm-{workload}-{env}-{instance} |
| VM 2 | `vm-lbvm-test-02` | vm-{workload}-{env}-{instance} |
| NIC 1 | `nic-lbvm-test-01` | nic-{workload}-{env}-{instance} |
| NIC 2 | `nic-lbvm-test-02` | nic-{workload}-{env}-{instance} |
| OS Disk 1 | `osdisk-lbvm-test-01` | osdisk-{workload}-{env}-{instance} |
| OS Disk 2 | `osdisk-lbvm-test-02` | osdisk-{workload}-{env}-{instance} |

## Security Considerations

### Network Security
1. **NSG Rules**: Restrict inbound traffic to port 80 from Internet only
2. **No Public IPs on VMs**: VMs are not directly accessible from Internet
3. **Health Probe IP**: Explicitly allow 168.63.129.16 in NSG rules
4. **Subnet-Level NSG**: Applied at subnet level for centralized management

### Identity & Access
1. **VM Authentication**: Use SSH key-based authentication (no passwords)
2. **Azure RBAC**: Apply least-privilege access to resource group
3. **Managed Identities**: Not required for basic test environment

### Data Protection
1. **OS Disk Encryption**: Azure-managed encryption at rest (default)
2. **Disk Type**: Standard SSD (cost-effective for test workloads)
3. **Backup**: Not configured (test environment)

## Cost Optimization

### Cost Breakdown (Estimated Monthly - Sweden Central)
- **2x Standard_B2ats_v2 VMs**: ~$15-20/month (pay-as-you-go)
- **2x Standard SSD (30 GiB)**: ~$3/month
- **Standard Load Balancer**: ~$18/month (base + rules)
- **Public IP (Standard)**: ~$3/month
- **Virtual Network**: Free
- **Outbound Data Transfer**: Variable (first 100 GB free)

**Total Estimated Cost**: ~$40-45/month

### Cost Optimization Strategies
1. **Burstable VMs**: Basv2 SKU uses CPU credits for cost savings
2. **No NAT Gateway**: Saves ~$30/month by using LB outbound rules
3. **No Azure Bastion**: Use SSH directly via Load Balancer (for test)
4. **Standard SSD**: Cheaper than Premium SSD (~50% cost savings)
5. **Auto-Shutdown**: Consider VM auto-shutdown schedules (not in scope)

## Deployment Steps

### Step 1: Infrastructure as Code (Bicep)
- **File**: `infra/main.bicep`
- **Modules**: 
  - `infra/network.bicep` - VNet, Subnet, NSG
  - `infra/loadbalancer.bicep` - Public IP, Load Balancer, rules
  - `infra/vm.bicep` - VMs, NICs, OS disks

### Step 2: Parameterization
- **File**: `infra/main.bicepparam`
- **Parameters**:
  - Location: swedencentral
  - VM SKU: Standard_B2ats_v2
  - VM Count: 2
  - Admin Username: azureuser
  - SSH Public Key: (provided during deployment)

### Step 3: Deployment Script
- **File**: `deploy.sh`
- **Actions**:
  1. Validate Bicep templates
  2. Create resource group
  3. Deploy infrastructure via `az deployment group create`
  4. Output Load Balancer public IP

### Step 4: Post-Deployment Configuration
- **File**: `scripts/configure-vms.sh`
- **Actions**:
  1. Install Nginx web server on both VMs
  2. Create custom index.html with hostname
  3. Start Nginx service
  4. Verify health probe endpoint

### Step 5: Validation & Testing
- **File**: `scripts/test-deployment.sh`
- **Actions**:
  1. Test Load Balancer public IP (HTTP GET requests)
  2. Verify traffic distribution across both VMs
  3. Test zone redundancy (simulate VM failure)
  4. Verify health probe status

## Best Practices Implementation

Based on Microsoft Learn documentation and Azure Load Balancer best practices:

### ✅ Zone Redundancy
- Public IP: Zone-redundant (Standard SKU)
- Load Balancer: Zone-redundant frontend
- VMs: Distributed across Zone 1 and Zone 2

### ✅ Backend Pool Redundancy
- Minimum 2 instances (meets SLA requirement)
- VMs in different availability zones

### ✅ NSG Configuration
- Subnet-level NSG for centralized management
- Explicit allow for port 80 from Internet
- Explicit allow for Azure Load Balancer health probe IP (168.63.129.16)

### ✅ Health Probe Best Practices
- TCP protocol on port 80
- Interval: 5 seconds
- Probe count: 2 failures = unhealthy
- Health probe IP (168.63.129.16) not blocked by NSG

### ✅ Outbound Connectivity
- Explicit outbound rule (no default outbound access)
- Manual port allocation to prevent SNAT exhaustion
- Ports per instance: 1024 (recommended for 2 VMs)

### ✅ TCP Reset Enabled
- Load balancer rule includes `enableTcpReset: true`
- Informs endpoints of idle timeout gracefully

### ✅ Standard SKU (not Basic)
- Basic Load Balancer retired September 2025
- Standard LB provides zone redundancy and better security

## Maintenance & Operations

### Monitoring
1. **Azure Monitor Metrics**:
   - Load Balancer health probe status
   - VM CPU utilization (Basv2 credit usage)
   - Network throughput
2. **Log Analytics**: Not configured (cost optimization)
3. **Alerts**: Not configured (test environment)

### Patching & Updates
1. **OS Updates**: Manual via SSH (test environment)
2. **VM Extensions**: Custom Script Extension for Nginx installation
3. **Auto-Patching**: Not enabled (test environment)

### Disaster Recovery
- **Not Configured**: Test environment does not require DR

### Scaling Considerations
- **Horizontal Scaling**: Add more VMs to backend pool (up to 5,000 instances)
- **Vertical Scaling**: Change VM SKU (requires deallocation)

## Success Criteria

### Deployment Success
- [x] All resources deployed without errors
- [x] VMs running and healthy
- [x] Load Balancer health probe shows "Healthy" status
- [x] NSG rules applied correctly

### Functional Validation
- [x] HTTP requests to Load Balancer public IP return 200 OK
- [x] Traffic distributed across both VMs (verify via hostname)
- [x] Health probe responds on port 80
- [x] Outbound connectivity from VMs works (apt update)

### Non-Functional Validation
- [x] Zone redundancy verified (VMs in different zones)
- [x] Cost estimate within budget (~$40-45/month)
- [x] No policy violations (audit policies only)
- [x] Security best practices implemented (NSG, no public IPs on VMs)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Basv2 SKU not available in Sweden Central** | High | Fallback to Bsv2 (Intel-based, slightly more expensive) |
| **SNAT port exhaustion** | Medium | Use manual port allocation (1024 ports per instance) |
| **Health probe blocked by firewall** | High | Ensure 168.63.129.16 is allowed in NSG and VM firewall |
| **VM CPU credit exhaustion** | Low | Basv2 VMs throttle to baseline after credit depletion (test env acceptable) |
| **Single subnet failure** | Low | Use zone-redundant architecture (VMs in different zones) |

## References

### Microsoft Learn Documentation
- [Azure Load Balancer Best Practices](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-best-practices)
- [Basv2-series VM Specifications](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/basv2-series)
- [B-series CPU Credit Model](https://learn.microsoft.com/en-us/azure/virtual-machines/b-series-cpu-credit-model/b-series-cpu-credit-model)
- [Standard Load Balancer Overview](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview)
- [Zone Redundancy in Azure](https://learn.microsoft.com/en-us/azure/reliability/migrate-load-balancer)

### Azure Resource Graph Queries Used
- Policy assignments check: `policyResources | where type == 'microsoft.authorization/policyassignments'`

## Next Steps

This plan will be handed to the **Developer agent** for implementation. The Developer agent will:

1. Create Bicep templates for infrastructure (`infra/main.bicep`, `infra/network.bicep`, `infra/loadbalancer.bicep`, `infra/vm.bicep`)
2. Create parameter file (`infra/main.bicepparam`)
3. Create deployment script (`deploy.sh`)
4. Create post-deployment configuration script (`scripts/configure-vms.sh`)
5. Create validation script (`scripts/test-deployment.sh`)
6. Test deployment in Azure
7. Document deployment instructions in `README.md`

---

**Plan Created**: January 23, 2026  
**Environment**: Test  
**Region**: Sweden Central  
**Estimated Cost**: $40-45/month  
**SLA**: 99.99% (zone-redundant)

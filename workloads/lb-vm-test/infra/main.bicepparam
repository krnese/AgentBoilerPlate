// ============================================================================
// Bicep Parameters File - Default Configuration for Test Environment
// ============================================================================
// This parameter file provides default values for the infrastructure deployment.
// Override these values during deployment using CLI parameters if needed.
// ============================================================================

using './main.bicep'

// ============================================================================
// REQUIRED PARAMETERS (must be provided during deployment)
// ============================================================================

// Resource group name
param resourceGroupName = 'rg-lbvm-test-swedencentral'

// SSH public key for VM authentication
// Example: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... user@host
// Generate: ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
param sshPublicKey = '' // MUST be provided via --parameters sshPublicKey="..."

// ============================================================================
// INFRASTRUCTURE CONFIGURATION
// ============================================================================

// Azure region - Sweden Central (cost-effective for test workloads)
param location = 'swedencentral'

// Environment identifier
param environment = 'test'

// Workload name (used in resource naming)
param workloadName = 'lbvm'

// ============================================================================
// VIRTUAL MACHINE CONFIGURATION
// ============================================================================

// VM SKU - Basv2-series AMD (cheapest burstable option)
// Alternative: 'Standard_B1s' (even cheaper, 1 vCPU)
param vmSku = 'Standard_B2ats_v2'

// Number of VMs (minimum 2 for zone redundancy SLA)
param vmCount = 2

// VM admin username
param adminUsername = 'azureuser'

// OS disk size in GB (30 GB is sufficient for Ubuntu + Nginx)
param osDiskSizeGB = 30

// Ubuntu 22.04 LTS image (Canonical official image)
param osImageReference = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}

// Availability zones (Zone 1 and Zone 2 for redundancy)
param availabilityZones = [
  '1'
  '2'
]

// ============================================================================
// NETWORK CONFIGURATION
// ============================================================================

// Virtual Network address space (10.0.0.0/16 = 65,536 IPs)
param vnetAddressPrefix = '10.0.0.0/16'

// Subnet for VMs (10.0.1.0/24 = 256 IPs, 251 usable)
param subnetAddressPrefix = '10.0.1.0/24'

// ============================================================================
// RESOURCE TAGS
// ============================================================================

param tags = {
  Environment: 'test'
  Workload: 'lbvm'
  ManagedBy: 'Bicep'
  CostCenter: 'Test'
  Deployment: 'Automated'
  Owner: 'DevOps'
}

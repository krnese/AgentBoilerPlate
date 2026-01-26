// ============================================================================
// Main Bicep Template - Azure Load Balancer with 2 VMs (Test Environment)
// ============================================================================
// This template orchestrates the deployment of a zone-redundant architecture:
// - Resource Group creation
// - 2 Linux VMs (Ubuntu 22.04 LTS) distributed across availability zones
// - Standard Load Balancer with zone-redundant frontend
// - Virtual Network with dedicated subnet and NSG
// - All resources deployed in Sweden Central
// ============================================================================

targetScope = 'subscription'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Azure region for all resources')
param location string = 'swedencentral'

@description('Environment name (used in resource naming)')
@allowed([
  'test'
  'dev'
  'prod'
])
param environment string = 'test'

@description('Workload name (used in resource naming)')
param workloadName string = 'lbvm'

@description('Resource group name')
param resourceGroupName string = 'rg-lbvm-test-swedencentral'

@description('Virtual machine SKU')
param vmSku string = 'Standard_B2ats_v2'

@description('Number of VMs to deploy')
@minValue(2)
@maxValue(10)
param vmCount int = 2

@description('VM admin username')
param adminUsername string = 'azureuser'

@description('SSH public key for VM authentication')
@secure()
param sshPublicKey string

@description('Virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet address prefix')
param subnetAddressPrefix string = '10.0.1.0/24'

@description('Ubuntu OS image configuration')
param osImageReference object = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}

@description('OS disk size in GB')
param osDiskSizeGB int = 30

@description('Availability zones for VM deployment')
param availabilityZones array = [
  '1'
  '2'
]

@description('Tags to apply to all resources')
param tags object = {
  Environment: environment
  Workload: workloadName
  ManagedBy: 'Bicep'
  CostCenter: 'Test'
}

// ============================================================================
// VARIABLES
// ============================================================================

var deploymentId = uniqueString(resourceGroupName, deployment().name)

// ============================================================================
// RESOURCE: RESOURCE GROUP
// ============================================================================

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ============================================================================
// MODULE: NETWORK (VNet, Subnet, NSG)
// ============================================================================

module network 'network.bicep' = {
  scope: rg
  name: 'deploy-network-${deploymentId}'
  params: {
    location: location
    workloadName: workloadName
    environment: environment
    vnetAddressPrefix: vnetAddressPrefix
    subnetAddressPrefix: subnetAddressPrefix
    tags: tags
  }
}

// ============================================================================
// MODULE: LOAD BALANCER (Public IP, LB, Health Probe, Rules)
// ============================================================================

module loadbalancer 'loadbalancer.bicep' = {
  scope: rg
  name: 'deploy-loadbalancer-${deploymentId}'
  params: {
    location: location
    workloadName: workloadName
    environment: environment
    vmCount: vmCount
    tags: tags
  }
}

// ============================================================================
// MODULE: VIRTUAL MACHINES (VMs, NICs, OS Disks)
// ============================================================================

module virtualMachines 'vm.bicep' = {
  scope: rg
  name: 'deploy-vms-${deploymentId}'
  params: {
    location: location
    workloadName: workloadName
    environment: environment
    vmSku: vmSku
    vmCount: vmCount
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    subnetId: network.outputs.subnetId
    loadBalancerBackendPoolId: loadbalancer.outputs.backendPoolId
    osImageReference: osImageReference
    osDiskSizeGB: osDiskSizeGB
    availabilityZones: availabilityZones
    tags: tags
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Public IP address of the Load Balancer')
output loadBalancerPublicIp string = loadbalancer.outputs.publicIpAddress

@description('Load Balancer frontend IP configuration ID')
output loadBalancerFrontendIpConfigId string = loadbalancer.outputs.frontendIpConfigId

@description('Load Balancer backend pool ID')
output loadBalancerBackendPoolId string = loadbalancer.outputs.backendPoolId

@description('Virtual Network ID')
output vnetId string = network.outputs.vnetId

@description('Subnet ID')
output subnetId string = network.outputs.subnetId

@description('Network Security Group ID')
output nsgId string = network.outputs.nsgId

@description('VM resource IDs')
output vmIds array = virtualMachines.outputs.vmIds

@description('VM names')
output vmNames array = virtualMachines.outputs.vmNames

@description('VM private IP addresses')
output vmPrivateIps array = virtualMachines.outputs.vmPrivateIps

@description('Resource group name')
output resourceGroupName string = rg.name

@description('Deployment location')
output location string = location
output deploymentLocation string = location

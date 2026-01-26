// ============================================================================
// Network Module - Virtual Network, Subnet, and Network Security Group
// ============================================================================
// This module deploys:
// - Virtual Network with single subnet
// - Network Security Group with restrictive inbound rules
// - NSG attached at subnet level for centralized management
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Azure region for network resources')
param location string

@description('Workload name for resource naming')
param workloadName string

@description('Environment name for resource naming')
param environment string

@description('Virtual network address prefix')
param vnetAddressPrefix string

@description('Subnet address prefix')
param subnetAddressPrefix string

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var vnetName = 'vnet-${workloadName}-${environment}'
var subnetName = 'snet-vms'
var nsgName = 'nsg-${workloadName}-vms'

// Azure Load Balancer health probe source IP (well-known address)
var azureLoadBalancerProbeIp = '168.63.129.16'

// ============================================================================
// RESOURCE: NETWORK SECURITY GROUP
// ============================================================================

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowHTTPInbound'
        properties: {
          description: 'Allow HTTP traffic from Internet to VMs'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: subnetAddressPrefix
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAzureLoadBalancerInbound'
        properties: {
          description: 'Allow Azure Load Balancer health probes (required)'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInbound'
        properties: {
          description: 'Deny all other inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
    ]
  }
}

// ============================================================================
// RESOURCE: VIRTUAL NETWORK
// ============================================================================

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: nsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Virtual Network resource ID')
output vnetId string = vnet.id

@description('Virtual Network name')
output vnetName string = vnet.name

@description('Subnet resource ID')
output subnetId string = vnet.properties.subnets[0].id

@description('Subnet name')
output subnetName string = vnet.properties.subnets[0].name

@description('Network Security Group resource ID')
output nsgId string = nsg.id

@description('Network Security Group name')
output nsgName string = nsg.name

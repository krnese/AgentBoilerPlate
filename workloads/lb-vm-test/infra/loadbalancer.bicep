// ============================================================================
// Load Balancer Module - Public IP, Load Balancer, Health Probe, Rules
// ============================================================================
// This module deploys:
// - Zone-redundant Public IP (Standard SKU)
// - Standard Load Balancer with zone-redundant frontend
// - Health probe on TCP port 80
// - Load balancing rule for HTTP traffic
// - Outbound rule for internet access (no NAT Gateway)
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Azure region for load balancer resources')
param location string

@description('Workload name for resource naming')
param workloadName string

@description('Environment name for resource naming')
param environment string

@description('Number of VMs in backend pool (for outbound SNAT port calculation)')
param vmCount int

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var publicIpName = 'pip-${workloadName}-${environment}'
var loadBalancerName = 'lb-${workloadName}-${environment}'
var frontendIpConfigName = 'frontend-ip'
var backendPoolName = 'backend-pool'
var healthProbeName = 'health-probe-http'
var loadBalancingRuleName = 'lb-rule-http'
var outboundRuleName = 'outbound-rule'

// Calculate SNAT ports per instance (recommended: 1024 ports minimum)
// Total ports available: 64,000 - 1,024 (reserved) = 62,976
// For 2 VMs: 62,976 / 2 = 31,488 ports per instance (but we'll use 1024 for safety)
var outboundPortsPerInstance = 1024

// ============================================================================
// RESOURCE: PUBLIC IP ADDRESS (Zone-Redundant)
// ============================================================================

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: '${workloadName}-${environment}-${uniqueString(resourceGroup().id)}'
    }
  }
  zones: [] // Empty zones array = zone-redundant (covers all zones)
}

// ============================================================================
// RESOURCE: LOAD BALANCER (Standard SKU)
// ============================================================================

resource loadBalancer 'Microsoft.Network/loadBalancers@2023-11-01' = {
  name: loadBalancerName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: frontendIpConfigName
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
        zones: [] // Zone-redundant frontend
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
      }
    ]
    probes: [
      {
        name: healthProbeName
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 5
          numberOfProbes: 2
          probeThreshold: 1
        }
      }
    ]
    loadBalancingRules: [
      {
        name: loadBalancingRuleName
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, frontendIpConfigName)
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, healthProbeName)
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          enableTcpReset: true
          idleTimeoutInMinutes: 15
          loadDistribution: 'Default' // 5-tuple hash
          disableOutboundSnat: true // Use explicit outbound rule instead
        }
      }
    ]
    outboundRules: [
      {
        name: outboundRuleName
        properties: {
          frontendIPConfigurations: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, frontendIpConfigName)
            }
          ]
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, backendPoolName)
          }
          protocol: 'All'
          enableTcpReset: true
          idleTimeoutInMinutes: 15
          allocatedOutboundPorts: outboundPortsPerInstance
        }
      }
    ]
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Load Balancer resource ID')
output loadBalancerId string = loadBalancer.id

@description('Load Balancer name')
output loadBalancerName string = loadBalancer.name

@description('Public IP address (FQDN)')
output publicIpAddress string = publicIp.properties.ipAddress

@description('Public IP FQDN')
output publicIpFqdn string = publicIp.properties.dnsSettings.fqdn

@description('Frontend IP configuration ID')
output frontendIpConfigId string = loadBalancer.properties.frontendIPConfigurations[0].id

@description('Backend pool ID')
output backendPoolId string = loadBalancer.properties.backendAddressPools[0].id

@description('Health probe ID')
output healthProbeId string = loadBalancer.properties.probes[0].id

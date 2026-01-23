// ============================================================================
// Virtual Machines Module - VMs, NICs, OS Disks with Zone Redundancy
// ============================================================================
// This module deploys:
// - Multiple Linux VMs (Ubuntu 22.04 LTS) distributed across zones
// - Network interfaces attached to subnet and load balancer backend pool
// - Managed OS disks with Standard SSD
// - SSH key-based authentication (no passwords)
// - Custom Script Extension to install Nginx web server
// ============================================================================

targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Azure region for VM resources')
param location string

@description('Workload name for resource naming')
param workloadName string

@description('Environment name for resource naming')
param environment string

@description('VM SKU (e.g., Standard_B2ats_v2)')
param vmSku string

@description('Number of VMs to deploy')
param vmCount int

@description('VM admin username')
param adminUsername string

@description('SSH public key for authentication')
@secure()
param sshPublicKey string

@description('Subnet resource ID for NIC attachment')
param subnetId string

@description('Load Balancer backend pool ID')
param loadBalancerBackendPoolId string

@description('OS image reference')
param osImageReference object

@description('OS disk size in GB')
param osDiskSizeGB int

@description('Availability zones for VMs')
param availabilityZones array

@description('Resource tags')
param tags object

// ============================================================================
// VARIABLES
// ============================================================================

var vmNamePrefix = 'vm-${workloadName}-${environment}'
var nicNamePrefix = 'nic-${workloadName}-${environment}'
var osDiskNamePrefix = 'osdisk-${workloadName}-${environment}'

// Nginx installation script (cloud-init)
var customData = base64('''
#cloud-config
package_update: true
package_upgrade: true
packages:
  - nginx
runcmd:
  - systemctl enable nginx
  - systemctl start nginx
  - HOSTNAME=$(hostname)
  - echo "<html><head><title>$HOSTNAME</title></head><body><h1>Hello from $HOSTNAME</h1><p>This VM is part of the load-balanced backend pool.</p><p>Zone: $(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01&format=text")</p></body></html>" > /var/www/html/index.html
  - systemctl reload nginx
''')

// ============================================================================
// RESOURCE: NETWORK INTERFACE (NIC)
// ============================================================================

resource nic 'Microsoft.Network/networkInterfaces@2023-11-01' = [for i in range(0, vmCount): {
  name: '${nicNamePrefix}-${padLeft(i + 1, 2, '0')}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          loadBalancerBackendAddressPools: [
            {
              id: loadBalancerBackendPoolId
            }
          ]
        }
      }
    ]
    enableAcceleratedNetworking: false // Not supported on B-series VMs
    enableIPForwarding: false
  }
}]

// ============================================================================
// RESOURCE: VIRTUAL MACHINE
// ============================================================================

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = [for i in range(0, vmCount): {
  name: '${vmNamePrefix}-${padLeft(i + 1, 2, '0')}'
  location: location
  tags: tags
  zones: [
    availabilityZones[i % length(availabilityZones)]
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSku
    }
    storageProfile: {
      imageReference: osImageReference
      osDisk: {
        name: '${osDiskNamePrefix}-${padLeft(i + 1, 2, '0')}'
        createOption: 'FromImage'
        diskSizeGB: osDiskSizeGB
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        caching: 'ReadWrite'
      }
    }
    osProfile: {
      computerName: '${vmNamePrefix}-${padLeft(i + 1, 2, '0')}'
      adminUsername: adminUsername
      customData: customData
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: null // Use managed storage account (no cost)
      }
    }
  }
}]

// ============================================================================
// OUTPUTS
// ============================================================================

@description('VM resource IDs')
output vmIds array = [for i in range(0, vmCount): vm[i].id]

@description('VM names')
output vmNames array = [for i in range(0, vmCount): vm[i].name]

@description('VM private IP addresses')
output vmPrivateIps array = [for i in range(0, vmCount): nic[i].properties.ipConfigurations[0].properties.privateIPAddress]

@description('NIC resource IDs')
output nicIds array = [for i in range(0, vmCount): nic[i].id]

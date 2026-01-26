#!/bin/bash

# ============================================================================
# VM Configuration Script - Post-Deployment Setup
# ============================================================================
# This script configures the VMs after deployment by:
# - Installing and configuring Nginx web server (if cloud-init failed)
# - Creating custom HTML pages with hostname identification
# - Verifying health probe endpoint on port 80
# ============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# ============================================================================
# CONFIGURATION
# ============================================================================

RESOURCE_GROUP="rg-lbvm-test-swedencentral"
VM_NAME_PREFIX="vm-lbvm-test"
ADMIN_USERNAME="azureuser"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI is not installed."
        exit 1
    fi
    
    # Check if logged in
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Run 'az login' first."
        exit 1
    fi
    
    # Check if resource group exists
    if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
        log_error "Resource group not found: $RESOURCE_GROUP"
        log_error "Run ./deploy.sh first to create the infrastructure."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

get_vm_names() {
    log_info "Retrieving VM names from resource group..."
    
    VM_NAMES=$(az vm list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].name" \
        -o tsv)
    
    if [ -z "$VM_NAMES" ]; then
        log_error "No VMs found in resource group: $RESOURCE_GROUP"
        exit 1
    fi
    
    log_success "Found VMs: $(echo $VM_NAMES | tr '\n' ' ')"
}

configure_vm() {
    local vm_name=$1
    
    log_info "Configuring VM: $vm_name"
    
    # Run command script on VM
    local configure_script='
#!/bin/bash
set -e

echo "Starting VM configuration..."

# Check if Nginx is already installed
if systemctl is-active --quiet nginx; then
    echo "Nginx is already running"
else
    echo "Installing Nginx..."
    sudo apt-get update -qq
    sudo apt-get install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
fi

# Get hostname and zone information
HOSTNAME=$(hostname)
ZONE=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/compute/zone?api-version=2021-02-01&format=text" || echo "unknown")

# Create custom HTML page
echo "Creating custom HTML page..."
sudo bash -c "cat > /var/www/html/index.html" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>$HOSTNAME - Load Balancer Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        h1 {
            color: #0078d4;
        }
        .info {
            background-color: #e7f3ff;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
        .success {
            color: #107c10;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>✅ Load Balancer is Working!</h1>
        <div class="info">
            <p><strong>Hostname:</strong> $HOSTNAME</p>
            <p><strong>Availability Zone:</strong> Zone $ZONE</p>
            <p><strong>Web Server:</strong> Nginx</p>
            <p><strong>Request Time:</strong> <span id="time"></span></p>
        </div>
        <p class="success">This VM is part of the load-balanced backend pool.</p>
        <p>Refresh the page multiple times to see traffic distribution across VMs.</p>
    </div>
    <script>
        document.getElementById("time").textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Reload Nginx to apply changes
sudo systemctl reload nginx

# Verify Nginx is responding on port 80
if curl -s -o /dev/null -w "%{http_code}" http://localhost:80 | grep -q "200"; then
    echo "✅ Nginx is responding on port 80"
else
    echo "❌ Nginx is NOT responding on port 80"
    exit 1
fi

echo "VM configuration completed successfully"
'
    
    # Execute the script on the VM using run-command
    az vm run-command invoke \
        --resource-group "$RESOURCE_GROUP" \
        --name "$vm_name" \
        --command-id RunShellScript \
        --scripts "$configure_script" \
        --output none
    
    log_success "VM configuration completed: $vm_name"
}

verify_vm_health() {
    local vm_name=$1
    
    log_info "Verifying health probe endpoint on $vm_name..."
    
    # Check if port 80 is listening
    local verify_script='
#!/bin/bash
if ss -tuln | grep -q ":80 "; then
    echo "✅ Port 80 is listening"
    exit 0
else
    echo "❌ Port 80 is NOT listening"
    exit 1
fi
'
    
    az vm run-command invoke \
        --resource-group "$RESOURCE_GROUP" \
        --name "$vm_name" \
        --command-id RunShellScript \
        --scripts "$verify_script" \
        --query "value[0].message" \
        -o tsv
    
    log_success "Health probe verification passed: $vm_name"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo ""
    echo "================================================================"
    echo "VM Configuration Script - Post-Deployment Setup"
    echo "================================================================"
    echo ""
    
    check_prerequisites
    get_vm_names
    
    echo ""
    log_info "Starting VM configuration process..."
    echo ""
    
    # Configure each VM
    for vm_name in $VM_NAMES; do
        configure_vm "$vm_name"
        verify_vm_health "$vm_name"
        echo ""
    done
    
    echo "================================================================"
    log_success "All VMs configured successfully!"
    echo "================================================================"
    echo ""
    echo "Next Steps:"
    echo "1. Test the Load Balancer: ./scripts/test-deployment.sh"
    echo "2. Or manually: curl http://\$(az network public-ip show -g $RESOURCE_GROUP -n pip-lbvm-test --query ipAddress -o tsv)"
    echo ""
}

# Run main function
main "$@"

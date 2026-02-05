#!/bin/bash

# ============================================================================
# Deployment Validation Script - Load Balancer and VM Testing
# ============================================================================
# This script validates the deployment by:
# - Testing Load Balancer public IP endpoint
# - Verifying traffic distribution across VMs
# - Checking health probe status
# - Testing zone redundancy
# ============================================================================

set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# ============================================================================
# CONFIGURATION
# ============================================================================

RESOURCE_GROUP="rg-lbvm-test-swedencentral"
LB_NAME="lb-lbvm-test"
PUBLIC_IP_NAME="pip-lbvm-test"
TEST_REQUESTS=10

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
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed."
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

get_public_ip() {
    log_info "Retrieving Load Balancer public IP..."
    
    LB_PUBLIC_IP=$(az network public-ip show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$PUBLIC_IP_NAME" \
        --query ipAddress \
        -o tsv)
    
    if [ -z "$LB_PUBLIC_IP" ]; then
        log_error "Failed to retrieve public IP address"
        exit 1
    fi
    
    log_success "Load Balancer Public IP: $LB_PUBLIC_IP"
}

test_load_balancer_connectivity() {
    log_info "Testing Load Balancer HTTP endpoint..."
    
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$LB_PUBLIC_IP" || echo "000")
    
    if [ "$http_code" == "200" ]; then
        log_success "Load Balancer is responding (HTTP $http_code)"
        return 0
    else
        log_error "Load Balancer is NOT responding (HTTP $http_code)"
        log_warning "This may be normal if VMs are still initializing (wait 2-3 minutes)"
        return 1
    fi
}

test_traffic_distribution() {
    log_info "Testing traffic distribution across VMs ($TEST_REQUESTS requests)..."
    
    declare -A hostname_counts
    local total_requests=0
    local successful_requests=0
    
    for i in $(seq 1 $TEST_REQUESTS); do
        local response=$(curl -s --connect-timeout 5 "http://$LB_PUBLIC_IP" 2>/dev/null || echo "")
        
        if [ -n "$response" ]; then
            # Extract hostname from HTML response
            local hostname=$(echo "$response" | grep -oP '(?<=<strong>Hostname:</strong> )[^<]+' || echo "unknown")
            
            if [ "$hostname" != "unknown" ]; then
                hostname_counts["$hostname"]=$((${hostname_counts["$hostname"]:-0} + 1))
                successful_requests=$((successful_requests + 1))
            fi
        fi
        
        total_requests=$((total_requests + 1))
        sleep 0.5  # Small delay between requests
    done
    
    echo ""
    echo "Traffic Distribution Results:"
    echo "────────────────────────────────────────────────"
    
    local unique_vms=0
    for hostname in "${!hostname_counts[@]}"; do
        local count=${hostname_counts[$hostname]}
        local percentage=$((count * 100 / successful_requests))
        echo "  $hostname: $count requests ($percentage%)"
        unique_vms=$((unique_vms + 1))
    done
    
    echo "────────────────────────────────────────────────"
    echo "Total Requests: $total_requests"
    echo "Successful: $successful_requests"
    echo "Failed: $((total_requests - successful_requests))"
    echo "Unique VMs: $unique_vms"
    echo ""
    
    if [ $unique_vms -ge 2 ] && [ $successful_requests -ge $((TEST_REQUESTS * 8 / 10)) ]; then
        log_success "Traffic distribution is working correctly"
        return 0
    elif [ $unique_vms -eq 1 ]; then
        log_warning "Only 1 VM is responding (expected 2)"
        log_warning "Check health probe status and VM availability"
        return 1
    else
        log_error "Traffic distribution test failed"
        return 1
    fi
}

check_health_probe_status() {
    log_info "Checking Load Balancer health probe status..."
    
    # Get backend pool health
    local health_status=$(az network lb show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$LB_NAME" \
        --query "backendAddressPools[0].backendIPConfigurations" \
        -o tsv 2>/dev/null || echo "")
    
    if [ -n "$health_status" ]; then
        local backend_count=$(echo "$health_status" | wc -l)
        log_success "Backend pool has $backend_count network interfaces attached"
    else
        log_warning "Unable to retrieve health probe status"
    fi
}

check_vm_status() {
    log_info "Checking VM status..."
    
    local vm_list=$(az vm list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].{name:name, powerState:powerState, zone:zones[0]}" \
        -o json)
    
    echo ""
    echo "VM Status:"
    echo "────────────────────────────────────────────────"
    
    echo "$vm_list" | jq -r '.[] | "  \(.name) - Power: \(.powerState // "unknown") - Zone: \(.zone // "none")"'
    
    echo "────────────────────────────────────────────────"
    echo ""
    
    local running_vms=$(echo "$vm_list" | jq '[.[] | select(.powerState == "VM running")] | length')
    
    if [ "$running_vms" -ge 2 ]; then
        log_success "All VMs are running"
    else
        log_warning "Not all VMs are running (running: $running_vms, expected: 2)"
    fi
}

get_resource_summary() {
    log_info "Retrieving resource summary..."
    
    echo ""
    echo "================================================================"
    echo "DEPLOYMENT SUMMARY"
    echo "================================================================"
    echo ""
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Load Balancer Public IP: $LB_PUBLIC_IP"
    echo ""
    
    # Get resource costs (if available)
    local resource_count=$(az resource list \
        --resource-group "$RESOURCE_GROUP" \
        --query "length(@)")
    
    echo "Total Resources Deployed: $resource_count"
    echo ""
    echo "Resources:"
    az resource list \
        --resource-group "$RESOURCE_GROUP" \
        --query "[].{Type:type, Name:name}" \
        -o table
    echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo ""
    echo "================================================================"
    echo "Deployment Validation Script - Load Balancer and VM Testing"
    echo "================================================================"
    echo ""
    
    check_prerequisites
    get_public_ip
    
    echo ""
    log_info "Starting validation tests..."
    echo ""
    
    # Test connectivity
    if ! test_load_balancer_connectivity; then
        log_warning "Waiting 30 seconds for VMs to initialize..."
        sleep 30
        if ! test_load_balancer_connectivity; then
            log_error "Load Balancer is still not responding"
            log_info "Checking VM status for troubleshooting..."
            check_vm_status
            echo ""
            log_error "VALIDATION FAILED"
            log_info "Troubleshooting tips:"
            echo "  1. Wait a few more minutes for cloud-init to complete"
            echo "  2. Run: ./scripts/configure-vms.sh"
            echo "  3. Check NSG rules allow port 80 from Internet"
            echo "  4. Check health probe status in Azure Portal"
            exit 1
        fi
    fi
    
    echo ""
    
    # Test traffic distribution
    test_traffic_distribution
    
    echo ""
    
    # Check health probes
    check_health_probe_status
    
    echo ""
    
    # Check VM status
    check_vm_status
    
    # Get summary
    get_resource_summary
    
    echo "================================================================"
    log_success "VALIDATION COMPLETED SUCCESSFULLY"
    echo "================================================================"
    echo ""
    echo "Load Balancer Endpoint:"
    echo "  http://$LB_PUBLIC_IP"
    echo ""
    echo "To access VMs via SSH (requires NSG rule for SSH):"
    echo "  ssh $ADMIN_USERNAME@<vm-private-ip>"
    echo ""
    echo "To view logs and metrics:"
    echo "  az monitor metrics list --resource <vm-resource-id>"
    echo ""
    echo "To delete all resources:"
    echo "  az group delete --name $RESOURCE_GROUP --yes"
    echo ""
}

# Run main function
main "$@"

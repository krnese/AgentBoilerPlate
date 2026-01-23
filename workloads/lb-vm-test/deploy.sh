#!/bin/bash

# ============================================================================
# Azure Infrastructure Deployment Script
# ============================================================================
# This script deploys the Azure Load Balancer with 2 VMs infrastructure
# using Bicep templates. It handles resource group creation, validation,
# and deployment.
# ============================================================================

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Exit on pipe failure

# ============================================================================
# CONFIGURATION
# ============================================================================

DEPLOYMENT_NAME="lb-vm-deployment-$(date +%Y%m%d-%H%M%S)"
RESOURCE_GROUP="rg-lbvm-test-swedencentral"
LOCATION="swedencentral"
BICEP_FILE="./infra/main.bicep"
PARAM_FILE="./infra/main.bicepparam"

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
        log_error "Azure CLI is not installed. Please install it from https://aka.ms/azure-cli"
        exit 1
    fi
    
    # Check if logged in to Azure
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Display current subscription
    SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    log_success "Logged in to Azure subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)"
    
    # Check if Bicep file exists
    if [ ! -f "$BICEP_FILE" ]; then
        log_error "Bicep file not found: $BICEP_FILE"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

validate_ssh_key() {
    if [ -z "${SSH_PUBLIC_KEY:-}" ]; then
        log_warning "SSH_PUBLIC_KEY environment variable not set."
        
        # Check if default SSH key exists
        if [ -f ~/.ssh/id_rsa.pub ]; then
            log_info "Found SSH public key at ~/.ssh/id_rsa.pub"
            SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
            log_success "Using default SSH public key"
        else
            log_error "No SSH public key found. Please generate one using:"
            log_error "  ssh-keygen -t rsa -b 4096 -C 'your_email@example.com'"
            log_error "Or set SSH_PUBLIC_KEY environment variable:"
            log_error "  export SSH_PUBLIC_KEY=\$(cat ~/.ssh/id_rsa.pub)"
            exit 1
        fi
    fi
    
    log_success "SSH public key validation passed"
}

create_resource_group() {
    log_info "Checking if resource group exists: $RESOURCE_GROUP"
    
    if az group show --name "$RESOURCE_GROUP" &> /dev/null; then
        log_warning "Resource group already exists: $RESOURCE_GROUP"
    else
        log_info "Creating resource group: $RESOURCE_GROUP in $LOCATION"
        az group create \
            --name "$RESOURCE_GROUP" \
            --location "$LOCATION" \
            --output none
        log_success "Resource group created: $RESOURCE_GROUP"
    fi
}

validate_deployment() {
    log_info "Validating Bicep template..."
    
    az deployment group validate \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$BICEP_FILE" \
        --parameters "$PARAM_FILE" \
        --parameters sshPublicKey="$SSH_PUBLIC_KEY" \
        --output none
    
    log_success "Template validation passed"
}

deploy_infrastructure() {
    log_info "Deploying infrastructure (this may take 5-10 minutes)..."
    log_info "Deployment name: $DEPLOYMENT_NAME"
    
    az deployment group create \
        --name "$DEPLOYMENT_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --template-file "$BICEP_FILE" \
        --parameters "$PARAM_FILE" \
        --parameters sshPublicKey="$SSH_PUBLIC_KEY" \
        --output none
    
    log_success "Infrastructure deployment completed"
}

get_outputs() {
    log_info "Retrieving deployment outputs..."
    
    LB_PUBLIC_IP=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query properties.outputs.loadBalancerPublicIp.value \
        -o tsv)
    
    VM_NAMES=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query properties.outputs.vmNames.value \
        -o tsv)
    
    VM_PRIVATE_IPS=$(az deployment group show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$DEPLOYMENT_NAME" \
        --query properties.outputs.vmPrivateIps.value \
        -o tsv)
    
    echo ""
    echo "================================================================"
    log_success "DEPLOYMENT COMPLETED SUCCESSFULLY"
    echo "================================================================"
    echo ""
    echo "Load Balancer Public IP: $LB_PUBLIC_IP"
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Location: $LOCATION"
    echo ""
    echo "Virtual Machines:"
    echo "$VM_NAMES" | while read -r vm_name; do
        echo "  - $vm_name"
    done
    echo ""
    echo "VM Private IPs:"
    echo "$VM_PRIVATE_IPS" | while read -r ip; do
        echo "  - $ip"
    done
    echo ""
    echo "================================================================"
    echo "NEXT STEPS:"
    echo "================================================================"
    echo "1. Wait 2-3 minutes for VMs to complete initialization"
    echo "2. Test Load Balancer: curl http://$LB_PUBLIC_IP"
    echo "3. Run validation script: ./scripts/test-deployment.sh"
    echo "4. Configure VMs: ./scripts/configure-vms.sh (if needed)"
    echo ""
    echo "To view resources in Azure Portal:"
    echo "https://portal.azure.com/#@/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
    echo "================================================================"
    echo ""
}

cleanup_on_error() {
    log_error "Deployment failed. Check the error messages above."
    log_info "To retry, fix the errors and run this script again."
    log_info "To delete the resource group: az group delete --name $RESOURCE_GROUP --yes"
    exit 1
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    echo ""
    echo "================================================================"
    echo "Azure Load Balancer with 2 VMs - Deployment Script"
    echo "================================================================"
    echo ""
    
    # Set error trap
    trap cleanup_on_error ERR
    
    # Execute deployment steps
    check_prerequisites
    validate_ssh_key
    create_resource_group
    validate_deployment
    deploy_infrastructure
    get_outputs
    
    log_success "Deployment script completed successfully!"
}

# Run main function
main "$@"

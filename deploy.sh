#!/bin/bash

# OpenVPN Terraform Deployment Script
# This script automates all the required steps to deploy OpenVPN infrastructure on AWS

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform >= 1.12.2"
        print_info "Visit: https://www.terraform.io/downloads.html"
        exit 1
    fi
    
    # Check terraform version
    TERRAFORM_VERSION=$(terraform version | head -n1 | cut -d' ' -f2 | sed 's/v//')
    print_info "Found Terraform version: $TERRAFORM_VERSION"
    
    # Check if AWS credentials are configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_warning "AWS credentials not found or not configured"
        print_info "Please configure AWS credentials using one of these methods:"
        print_info "  1. aws configure"
        print_info "  2. Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables"
        print_info "  3. Use IAM roles (if running on EC2)"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "AWS credentials found"
    fi
    
    print_success "Prerequisites check completed"
}

# Function to check if terraform.tfvars exists
check_tfvars() {
    print_header "Checking Configuration"
    
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars file not found"
        print_info "You need to create a terraform.tfvars file with the following variables:"
        echo
        cat << 'EOF'
public_subnet_az   = "<your-aws-availability-zone>"
private_subnet1_az = "<your-aws-availability-zone>"
private_subnet2_az = "<your-aws-availability-zone>"
ssh_public_key_path    = "/path/to/your/public_key.pub"
ssh_key_name           = "<your-ssh-key-name>"
openvpn_admin_user     = "<your-admin-username>"
openvpn_admin_password = "<your-secure-password>"
instance_type          = "t3.micro"
EOF
        echo
        print_info "Example values:"
        print_info "  public_subnet_az   = \"us-east-1a\""
        print_info "  private_subnet1_az = \"us-east-1b\""
        print_info "  private_subnet2_az = \"us-east-1c\""
        print_info "  ssh_public_key_path    = \"~/.ssh/id_rsa.pub\""
        print_info "  ssh_key_name           = \"my-openvpn-key\""
        print_info "  openvpn_admin_user     = \"vpnadmin\""
        print_info "  openvpn_admin_password = \"SecurePassword123!\""
        print_info "  instance_type          = \"t3.micro\""
        echo
        read -p "Would you like to create terraform.tfvars now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_tfvars_interactive
        else
            print_error "terraform.tfvars is required. Please create it and run this script again."
            exit 1
        fi
    else
        print_success "terraform.tfvars file found"
    fi
}

# Function to interactively create terraform.tfvars
create_tfvars_interactive() {
    print_info "Creating terraform.tfvars interactively..."
    echo
    
    read -p "Enter public subnet availability zone (e.g., us-east-1a): " public_az
    read -p "Enter private subnet 1 availability zone (e.g., us-east-1b): " private1_az
    read -p "Enter private subnet 2 availability zone (e.g., us-east-1c): " private2_az
    read -p "Enter path to SSH public key (e.g., ~/.ssh/id_rsa.pub): " ssh_key_path
    read -p "Enter SSH key name: " ssh_key_name
    read -p "Enter OpenVPN admin username: " admin_user
    read -s -p "Enter OpenVPN admin password (min 8 chars): " admin_password
    echo
    read -p "Enter EC2 instance type [t3.micro]: " instance_type
    instance_type=${instance_type:-t3.micro}
    
    # Expand tilde in ssh_key_path
    ssh_key_path="${ssh_key_path/#\~/$HOME}"
    
    # Create terraform.tfvars
    cat > terraform.tfvars << EOF
public_subnet_az   = "$public_az"
private_subnet1_az = "$private1_az"
private_subnet2_az = "$private2_az"
ssh_public_key_path    = "$ssh_key_path"
ssh_key_name           = "$ssh_key_name"
openvpn_admin_user     = "$admin_user"
openvpn_admin_password = "$admin_password"
instance_type          = "$instance_type"
EOF
    
    print_success "terraform.tfvars created successfully"
}

# Function to setup terraform workspace
setup_workspace() {
    print_header "Setting up Terraform Workspace"
    
    print_info "Creating or selecting 'dev' workspace..."
    if terraform workspace new dev 2>/dev/null; then
        print_success "Created new 'dev' workspace"
    else
        terraform workspace select dev
        print_success "Selected existing 'dev' workspace"
    fi
}

# Function to run terraform initialization
terraform_init() {
    print_header "Initializing Terraform"
    
    print_info "Running terraform init..."
    terraform init -input=false
    print_success "Terraform initialization completed"
}

# Function to format check
terraform_format_check() {
    print_header "Checking Terraform Format"
    
    print_info "Running terraform format check..."
    if terraform fmt -check -recursive; then
        print_success "Terraform format check passed"
    else
        print_warning "Terraform format check found issues. Running terraform fmt to fix..."
        terraform fmt -recursive
        print_success "Terraform format issues fixed"
    fi
}

# Function to validate terraform configuration
terraform_validate() {
    print_header "Validating Terraform Configuration"
    
    print_info "Running terraform validate..."
    terraform validate
    print_success "Terraform validation completed"
}

# Function to run terraform plan
terraform_plan() {
    print_header "Planning Terraform Deployment"
    
    print_info "Running terraform plan..."
    terraform plan -out=tfplan
    print_success "Terraform plan completed. Plan saved to 'tfplan'"
    
    echo
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deployment cancelled by user"
        exit 0
    fi
}

# Function to apply terraform configuration
terraform_apply() {
    print_header "Applying Terraform Configuration"
    
    print_info "Running terraform apply..."
    terraform apply tfplan
    print_success "Terraform deployment completed!"
    
    # Clean up plan file
    rm -f tfplan
    
    echo
    print_header "Deployment Information"
    print_info "Your OpenVPN server has been deployed successfully!"
    print_info "Retrieving connection information..."
    echo
    terraform output -raw ip_address
    echo
}

# Function to destroy infrastructure
terraform_destroy() {
    print_header "Destroying Terraform Infrastructure"
    
    print_warning "This will destroy all infrastructure created by this project!"
    read -p "Are you sure you want to destroy the infrastructure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Running terraform destroy..."
        terraform destroy -auto-approve
        print_success "Infrastructure destroyed successfully"
    else
        print_info "Destroy cancelled by user"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  deploy    Deploy the OpenVPN infrastructure (default)"
    echo "  destroy   Destroy the OpenVPN infrastructure"
    echo "  plan      Run terraform plan only"
    echo "  help      Show this help message"
    echo
    echo "Examples:"
    echo "  $0                Deploy infrastructure"
    echo "  $0 deploy         Deploy infrastructure"
    echo "  $0 plan           Run plan only"
    echo "  $0 destroy        Destroy infrastructure"
}

# Main execution function
main() {
    local command=${1:-deploy}
    
    case $command in
        "deploy"|"")
            print_header "OpenVPN Terraform Deployment"
            check_prerequisites
            check_tfvars
            terraform_init
            setup_workspace
            terraform_format_check
            terraform_validate
            terraform_plan
            terraform_apply
            ;;
        "destroy")
            check_prerequisites
            terraform_destroy
            ;;
        "plan")
            check_prerequisites
            check_tfvars
            terraform_init
            setup_workspace
            terraform_format_check
            terraform_validate
            terraform_plan
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Check if aws CLI is available (optional check)
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_warning "AWS CLI is not installed. This is recommended but not required."
        print_info "Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Check if running from correct directory
    if [ ! -f "main.tf" ]; then
        print_error "This script must be run from the openvpn-terraform directory"
        print_info "Please cd to the openvpn-terraform directory and run this script again"
        exit 1
    fi
    
    # Check AWS CLI availability
    check_aws_cli
    
    # Run main function with all arguments
    main "$@"
fi
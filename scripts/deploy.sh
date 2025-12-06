#!/bin/bash
# One-Click Deployment Script

# --- Configuration ---
# Default values can be overridden via arguments
AWS_PROFILE="default"
AWS_REGION="us-east-1"
TF_VARS_FILE="../terraform/dev.tfvars"
TERRAFORM_DIR="../terraform"

# Function to display usage
usage() {
    echo "Usage: $0 [--profile <aws_profile>] [--region <aws_region>]"
    echo "Example: $0 --profile my-dev-profile --region us-west-2"
    exit 1
}

# Process command-line arguments
while (( "$#" )); do
  case "$1" in
    --profile)
      AWS_PROFILE=$2
      shift 2
      ;;
    --region)
      AWS_REGION=$2
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

echo "--- One-Click Deployment Started ---"
echo "AWS Profile: ${AWS_PROFILE}"
echo "AWS Region: ${AWS_REGION}"
echo "-------------------------------------"

# 1. Check for required tools
if ! command -v terraform &> /dev/null
then
    echo "Error: terraform command not found. Please install Terraform."
    exit 1
fi
if ! command -v aws &> /dev/null
then
    echo "Error: aws CLI command not found. Please install AWS CLI."
    exit 1
fi

# 2. Prepare Terraform
echo "1. Initializing Terraform..."
cd "$TERRAFORM_DIR" || exit
terraform init

# 3. Apply Infrastructure
echo "2. Planning Infrastructure..."
terraform plan -var-file="$TF_VARS_FILE" -var="aws_region=${AWS_REGION}" -out="tfplan"

echo "3. Applying Infrastructure (This may take a few minutes)..."
# Use auto-approve for true 'one-click' experience [cite: 27]
terraform apply -auto-approve "tfplan"

# 4. Cleanup plan file
rm -f tfplan

# 5. Get ALB DNS Name and run tests
echo "4. Deployment Complete. Retrieving ALB DNS Name..."
ALB_DNS=$(terraform output -raw alb_dns_name)

if [ -z "$ALB_DNS" ]; then
    echo "Error: Could not retrieve ALB DNS Name."
    exit 1
fi

echo "Application Load Balancer DNS: $ALB_DNS"
echo "-------------------------------------"
echo "Running automated test script..."
cd ../scripts || exit
./test.sh --dns "$ALB_DNS"

echo "--- Deployment Finished Successfully ---"
echo "You can manually test at: http://${ALB_DNS}/"
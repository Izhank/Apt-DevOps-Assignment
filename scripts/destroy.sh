#!/bin/bash
# Teardown / Destroy Script

# --- Configuration ---
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

echo "--- Teardown Started ---"
echo "AWS Profile: ${AWS_PROFILE}"
echo "AWS Region: ${AWS_REGION}"
echo "------------------------"

# 1. Check for required tools
if ! command -v terraform &> /dev/null
then
    echo "Error: terraform command not found. Please install Terraform."
    exit 1
fi

# 2. Destroy Infrastructure
echo "1. Destroying Infrastructure (This will remove all AWS resources)..."
cd "$TERRAFORM_DIR" || exit
# Use auto-approve for non-interactive destruction 
terraform destroy -var-file="$TF_VARS_FILE" -var="aws_region=${AWS_REGION}" -auto-approve

echo "--- Teardown Finished Successfully ---"
echo "All AWS resources have been destroyed."
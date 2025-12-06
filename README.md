# Apt DevOps Assignment: API Deployment

This repository contains the Infrastructure as Code (Terraform) and scripts required to deploy the Apt Node.js API.

## 🏗 Architecture
I designed this using a standard 3-tier architecture pattern:
* **Public Layer:** ALB (Application Load Balancer) & NAT Gateway in public subnets.
* **Private Layer:** EC2 instances (Auto Scaling Group) in private subnets.
* **Security:** instances are not reachable via SSH from the internet; they only accept traffic from the ALB.

## 📂 Project Structure
* `terraform/`: All IaC modules (VPC, ALB, ASG).
* `scripts/`: Helper scripts for deploy, destroy, and testing.
* `app/`: The Node.js application code.

## 🚀 Quick Start
**Prerequisites:** AWS CLI configured, Terraform v1.0+, Python3.

### 1. Deploy
I created a wrapper script to handle init and apply in one go:

```bash
chmod +x scripts/*.sh
scripts/deploy.sh --profile default --region us-east-1
```

### 2. Test
The deploy script runs tests automatically. You can also run them manually:

```bash
# Get the ALB DNS dynamically
DNS=$(python3 scripts/get_alb_dns.py)

# Hit the health endpoint
curl http://$DNS/health
```

### 3. Cleanup
To stop billing, run the destroy script:
```bash
scripts/destroy.sh --profile default --region us-east-1
```

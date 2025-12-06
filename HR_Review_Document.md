# Technical Summary - Mohammad Izhan

**Submission Date:** Dec 2025

## 📝 Approach & Architecture
For this assignment, I focused on isolation and security. I placed the application servers in **private subnets** to ensure they have no direct exposure to the internet.

* **Ingress:** Traffic enters via an internet-facing ALB (Port 80) and is forwarded to the private instances (Port 8080).
* **Egress:** I used a NAT Gateway so private instances can still download updates and reach CloudWatch without exposing public IPs.

## 🛠 Why Terraform?
I chose Terraform over CloudFormation because of its modularity. I broke the infrastructure into `vpc`, `alb`, and `asg` modules. This makes the code reusable and easier to read compared to a single monolithic file.

## 🔒 Security Decisions
1.  **No SSH Keys:** I did not attach SSH keys to the instances. Instead, I enabled **SSM Session Manager**. This allows secure shell access without opening port 22 to the world.
2.  **Security Groups:** The EC2 security group is strict—it *only* accepts traffic from the Load Balancer's security group.
3.  **Least Privilege:** The IAM role attached to the EC2s only has permissions for SSM and CloudWatch logging.

## ⚖️ Trade-offs & Future Improvements
* **State Management:** Currently, the Terraform state is local for simplicity. In a real production environment, I would use an S3 backend with DynamoDB locking (I had code for this but removed it for this standalone assignment).
* **HTTPS:** The ALB listens on HTTP (Port 80) for this demo. In production, I would attach an ACM certificate and enforce HTTPS.

## 🧪 Verification
I included a `test.sh` script that polls the ALB until it's healthy. You can verify the deployment by running:
`scripts/test.sh --dns <ALB_DNS_NAME>`

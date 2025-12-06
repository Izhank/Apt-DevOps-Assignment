output "alb_dns_name" {
  description = "The DNS name of the public-facing Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "List of Private Subnet IDs where EC2 instances reside"
  value       = module.vpc.private_subnet_ids
}

output "ec2_security_group_id" {
  description = "The Security Group ID for the EC2 instances"
  value       = aws_security_group.ec2_sg.id
}
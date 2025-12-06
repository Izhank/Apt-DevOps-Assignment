# --- Global Configuration ---
# Uses the 'aws_region' variable defined in variables.tf (or dev.tfvars)
# The provider is configured in provider.tf

# --- 1. VPC, Subnets, and Network Components ---
module "vpc" {
  source           = "./modules/vpc"
  project_name     = var.project_name
  vpc_cidr_block   = var.vpc_cidr_block
}

# --- 2. Security Groups & IAM Roles are defined directly in security_groups.tf ---
# These resources are referenced by the ALB and ASG modules

# --- 3. ALB and Target Group ---
module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id         = aws_security_group.alb_sg.id
}

# --- 4. Auto Scaling Group and Launch Template ---
module "asg" {
  source               = "./modules/asg"
  project_name         = var.project_name
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  ec2_sg_id            = aws_security_group.ec2_sg.id
  private_subnet_ids   = module.vpc.private_subnet_ids
  target_group_arn     = module.alb.target_group_arn
  min_size             = var.min_size
  max_size             = var.max_size
  instance_profile_arn = aws_iam_instance_profile.ec2_instance_profile.arn
  # key_pair_name = "your-key-name" # Uncomment and replace if needed for restricted SSH 
}
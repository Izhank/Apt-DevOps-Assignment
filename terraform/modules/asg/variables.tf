variable "project_name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "ec2_sg_id" {}
variable "private_subnet_ids" {
  type = list(string)
}
variable "target_group_arn" {}
variable "min_size" {}
variable "max_size" {}
variable "instance_profile_arn" {}
variable "key_pair_name" {
  default = null # Optional, set to your key name if you need to SSH (after restricting CIDR)
}
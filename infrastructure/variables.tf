variable "name" {
  description = "Name of the instance to be created."
  type        = string
}

variable "region" {
  description = "AWS region where the resources will be provisioned."
  type        = string
}

variable "profile" {
  description = "AWS profile to be used for authentication and authorization."
  type        = string
}

variable "managed_by" {
  description = "Name of the tool managing the resources (e.g., Terraform, CloudFormation, etc.)."
  type        = string
}

# variable "ami" {
#   description = "Amazon Machine Image (AMI) ID for provisioning EC2 instances."
#   type        = string
# }

variable "instance_type" {
  description = "EC2 instance type (e.g., t2.micro, m5.large, etc.)."
  type        = string
}

variable "volume_type" {
  description = "EBS volume type (e.g., gp2, io1, st1, sc1, etc.)."
  type        = string
}

variable "volume_size" {
  description = "Size of the EBS volume in GB."
  type        = number
}

variable "public_key" {
  description = "Public key value"
  type        = string
}

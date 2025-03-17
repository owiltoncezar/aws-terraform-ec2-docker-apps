data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

##################
# Security Groupv#
##################
resource "aws_security_group" "allow_ssh_and_docker" {
  name        = "EC2-${var.name}_Security_Group"
  description = "Allow SSH and traffic for Docker and Kind"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################
# EC2 Instance #
################

resource "aws_iam_role" "ec2_role" {
  name               = "EC2-${var.name}-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2-${var.name}-InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "ec2_instance" {
  ami                     = var.ami
  instance_type           = var.instance_type
  key_name                = var.key_name
  vpc_security_group_ids  = [aws_security_group.allow_ssh_and_docker.id]
  iam_instance_profile    = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id               = data.aws_subnets.default.ids[0]
  disable_api_termination = var.disable_api_termination

  #user_data = data.template_file.user_data.rendered

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    delete_on_termination = var.delete_on_termination
    encrypted             = true
  }

  tags = {
    Name      = "EC2-${var.name}"
    ManagedBy = var.managed_by
  }

  volume_tags = {
    Name      = "EC2-${var.name}"
    ManagedBy = var.managed_by
  }
}

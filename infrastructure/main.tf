# Obtém o ID da conta AWS
data "aws_caller_identity" "current" {}

# Obtém a AMI mais recente do Ubuntu (versão mais nova disponível)
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] # ID oficial da Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "key-par" {
  source     = "./key-par"
  profile    = var.profile
  region     = var.region
  name       = var.name
  public_key = var.public_key
  managed_by = var.managed_by
}

module "ec2_instance" {
  source        = "./ec2"
  profile       = var.profile
  region        = var.region
  managed_by    = var.managed_by
  ami           = data.aws_ami.ubuntu_latest.id
  key_name      = module.key-par.key
  name          = var.name
  instance_type = var.instance_type
  volume_type   = var.volume_type
  volume_size   = var.volume_size

  depends_on = [module.key-par]
}

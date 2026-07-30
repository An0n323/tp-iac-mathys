locals {
  prefixe = "${var.projet}-${var.environnement}"
  etiquettes = {
    Projet      = var.projet
    Environment = var.environnement
    ManagedBy   = "terraform"
    Owner       = var.proprietaire
  }
}

resource "aws_vpc" "principal" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${local.prefixe}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.principal.id
  tags   = { Name = "${local.prefixe}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.principal.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "${local.prefixe}-public-a" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.principal.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${local.prefixe}-rt-public" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name        = "${local.prefixe}-web"
  description = "HTTP public, SSH restreint a l IP de l administrateur"
  vpc_id      = aws_vpc.principal.id

  ingress {
    description = "HTTP depuis Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH depuis l IP d administration UNIQUEMENT"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_admin]
  }

  egress {
    description = "Sortie libre (mises a jour)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.prefixe}-sg-web" }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.nom_cle_ssh

  # ---- Durcissement obligatoire ----
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 imposé
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 10
  }

  user_data = <<-EOT
    #!/bin/bash
    set -euo pipefail
    apt-get update
    apt-get install -y nginx
    echo "${local.prefixe} — deploye par Terraform" > /var/www/html/index.html
    systemctl enable --now nginx
  EOT

  tags = { Name = "${local.prefixe}-web" }
}

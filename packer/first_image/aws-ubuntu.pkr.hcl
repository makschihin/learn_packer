############################################
# Load Packer Plugins
############################################
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

############################################
# Section of builder
############################################
source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

############################################
# Provisioner section
############################################
build {
  name    = "install nginx ansible"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    environment_vars = [
      "TEST=Hello",
    ]
    inline = [
      "echo Lets install nginx and ansible",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install nginx ansible -y",
      "echo \"TEST is $TEST\" > hello.txt",
    ]
  }
}

variable "ami_prefix" {
  type    = string
  default = "ubuntu-20.04-aws-nginx-ansible"
}

locals {  timestamp = regex_replace(timestamp(), "[- TZ:]", "")}

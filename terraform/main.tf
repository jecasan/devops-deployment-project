terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

# -- AMI Data Source --
data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"]

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
}

# -- Security Group : Jenkins --
resource "aws_security_group" "jenkins_sg" {
    name        = "jenkins-security-group"
    description = "Security group for Jenkins server"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.your_ip]
        description = "SSH from developer machine"
    }

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = [
            var.your_ip,
            "192.30.252.0/22",
            "185.199.108.0/22",
            "140.82.112.0/20",
            "143.55.64.0/20"
        ]
        description = "Jenkins UI from developer + GitHub webhook IPs"
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name    = "jenkins-sg"
        Project = "devops-portfolio"
    }
}

# -- Security Group: App Server -- 
resource "aws_security_group" "app_sg" {
    name        = "app-security-group"
    description = "Security group for application server"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.your_ip]
        description = "SSH from developer machine"
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        security_groups = [aws_security_group.jenkins_sg.id]
        description = "ssh from jenkins"
    }

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Public HTTP access"
    }

    egress {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name    = "app-sg"
        Project = "devops-portfolio"
    }
}

# -- EC2: Jenkins Server --
resource "aws_instance" "jenkins" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = var.instance_type
    key_name               = var.key_pair_name
    vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

    root_block_device {
        volume_size  = 20
        volume_type = "gp2"
    }

    tags = {
        Name    = "jenkins-server"
        Role    = "CI/CD"
        Project = "devops-portfolio"
    }
}

# -- EC2: App Server --
resource "aws_instance" "app_server" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = var.instance_type
    key_name               = var.key_pair_name
    vpc_security_group_ids = [aws_security_group.app_sg.id]

    root_block_device {
        volume_size  = 20
        volume_type = "gp2"
    }

    tags = {
        Name    = "app-server"
        Role    = "Application"
        Project = "devops-portfolio"
    }
}
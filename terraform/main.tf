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
        from_port  = 22
        to_port    = 22
        protocol   = "tcp"
        cidr_blocks = [var.your_ip]
    }

    ingress {
        from_port  = 8080
        to_port    = 8080
        protocol   = "tcp"
        cidr_blocks = [var.your_ip]
    }

    egress {
        from_port  = 0
        to_port    = 0
        protocol   = "-1"
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
        from_port  = 22
        to_port    = 22
        protocol   = "tcp"
        cidr_blocks = [var.your_ip]
    }

    ingress {
        from_port  = 80
        to_port    = 80
        protocol   = "tcp"
        cidr_blocks = [var.your_ip]
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
        Project = "devops-portfolio"
    }
}

# -- EC2: App Server --
resource "aws_instance" "app_server" {
    ami                    = data.aws_ami.ubuntu.id
    instance_type          = var.instance_type
    key_name               = var.key_pair_name
    vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

    root_block_device {
        volume_size  = 20
        volume_type = "gp2"
    }

    tags = {
        Name    = "app-server"
        Project = "devops-portfolio"
    }
}
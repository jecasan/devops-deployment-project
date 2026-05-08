variable "aws_region" {
    description = "AWS region to deploy resources"
    type        = string
    default     = "ap-southeast-2"
}

variable "key_pair_name" {
    description = "Name of your AWS EC2 key pair"
    type        = string
}

variable "your_ip" {
    description = "Your local IP for SSH access (format: x.x.x.x/32)"
    type        = string
}

variable "instance_type" {
    description = "EC2 instance type - must be free tier eligible"
    type        = string
    default     = "t3.micro"
}

variable "app_version" {
    description = "Application version tag"
    type        = string
    default     = "latest"
}
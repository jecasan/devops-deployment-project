output "jenkins_public_ip" {
    description = "Public IP of Jenkins server"
    value       = aws_instance.jenkins.public_ip
}

output "app_server_public_ip" {
    description = "Public IP of App server"
    value       = aws_instance.app_server.public_ip
}

output "jenkins_url" {
    description = "URL to access Jenkins"
    value       = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "app_url" {
    description = "URL to access the application"
    value       = "http://${aws_instance.app_server.public_ip}"
}
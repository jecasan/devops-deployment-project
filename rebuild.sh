#!/bin/bash
set -e

echo "Getting current IP..."
CURRENT_IP=$(curl -s ifconfig.me)
echo "Your IP: $CURRENT_IP"

echo "Updating terraform.tfvars..."
sed -i "s|your_ip.*=.*|your_ip = \"$CURRENT_IP/\" |" terraform?terraform.tfvars

echo "Applying security group update..."
cd terraform/
terraform apply -auto-approve


echo "Getting new server IPs..."
JENKINS_IP=$(terraform output -raw jenkins_public_ip)
APP_IP=$(terraform output -raw app_server_public_ip)
echo "Jenkins IP: $JENKINS_IP"
echo "App IP: $APP_IP"

echo "Updating Ansible inventory..."
cd ../ansible/
cat > inventory.ini << EOF
[jenkins]
$JENKINS_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/devops-key.pem

[app_servers]
$APP_IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/devops-key.pem

[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo "Running Ansible playbook..."
ansible-playbook -i inventory.ini playbook.yml

echo ""
echo "================================================"
echo " Rebuild complete!"
echo " Jenkins: http://$JENKINS_IP:8080"
echo " App:     http://$APP_IP"
echo "================================================"

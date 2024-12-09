#!/bin/bash

# Debugging echo
echo "Starting the deployment script..."

# Check if the argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <config-nr>"
  exit 1
fi

CONFIG_NR=$1

# Validate CONFIG_NR
echo "Validating CONFIG_NR..."
if [[ "$CONFIG_NR" == "1" || "$CONFIG_NR" == "3" || "$CONFIG_NR" == "5" ]]; then
  echo "CONFIG_NR is valid: $CONFIG_NR"
else
  echo "Invalid CONFIG_NR. It must be 1, 3, or 5."
  exit 1
fi

# Navigate to Terraform directory
echo "Changing to the terraform directory..."
cd terraform || { echo "Failed to change directory to terraform"; exit 1; }

# Initialize and apply Terraform
echo "Initializing Terraform..."
terraform init

echo "Applying Terraform configuration with vars/config$CONFIG_NR.tfvars..."
terraform apply -var-file="vars/config$CONFIG_NR.tfvars" -auto-approve

# Retrieve frontend public IP from Terraform output
echo "Retrieving frontend public IP..."
ANSIBLE_IP=$(terraform output -raw ansible_public_ip)

if [ -z "$ANSIBLE_IP" ]; then
  echo "Failed to retrieve frontend public IP from Terraform."
  exit 1
fi
echo "Frontend public IP: $ANSIBLE_IP"

ssh-keyscan $ANSIBLE_IP >> ~/.ssh/known_hosts
# Transfer files to the frontend server
echo "Transferring generated_key.pem to the frontend server..."
scp -i generated_key.pem generated_key.pem Admin123@"$ANSIBLE_IP":/home/Admin123/.ssh/generated_key.pem

echo "Transferring Ansible directory to the frontend server..."
scp -i generated_key.pem -r ../ansible Admin123@"$ANSIBLE_IP":/home/Admin123/

# SSH into the frontend server
echo "SSH into the frontend server to install Ansible..."
ssh -i generated_key.pem Admin123@"$ANSIBLE_IP" << 'EOF'
  echo "Changing to the Ansible directory..."
  cd ansible || { echo "Failed to change directory to ansible"; exit 1; }

  echo "Updating system packages..."
  sudo apt update -y

  echo "Installing required dependencies for Ansible..."
  sudo apt install -y software-properties-common

  echo "Adding Ansible PPA..."
  sudo add-apt-repository --yes --update ppa:ansible/ansible

  echo "Installing Ansible..."
  sudo apt install -y ansible

  echo "Installing Azure Ansible collection..."
  ansible-galaxy collection install azure.azcollection --force

  echo "Running Ansible playbook..."
  ansible-playbook -i inventory"$CONFIG_NR".yml site.yml
EOF

echo "Deployment script completed successfully."

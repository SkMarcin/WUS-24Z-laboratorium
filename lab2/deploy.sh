#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <config-nr>"
  exit 1
fi

CONFIG_NR=$1


if [[ "$CONFIG_NR" == "1" || "$CONFIG_NR" == "3" || "$CONFIG_NR" == "5" ]]; then
  echo "CONFIG_NR is valid: $CONFIG_NR"
else
  echo "Invalid CONFIG_NR. It must be 1, 3, or 5."
  exit 1
fi

cd terraform
terraform init
terraform apply "vars/config$CONFIG_NR.tfvars"

ANSIBLE_IP=$(terraform output -raw ansible_public_ip)

ssh-keyscan $ANSIBLE_IP >> ~/.ssh/known_hosts
scp -i generated_key.pem generated_key.pem Admin123@"$ANSIBLE_IP":/home/Admin123/.ssh/generated_key.pem
scp -i generated_key.pem -r ../ansible Admin123@"$ANSIBLE_IP":/home/Admin123/

ssh -i generated_key.pem Admin123@"$ANSIBLE_IP"
cd ansible

sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible-galaxy collection install azure.azcollection --force

ansible-playbook -i inventory"$CONFIG_NR".yml site.yml

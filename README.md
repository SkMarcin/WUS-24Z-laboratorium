# WUS-24Z-laboratorium
## Lab1
cd lab1
./deploy.sh <config_file>

### ssh
[ ~ ]$ ssh -i ~/.ssh/id_rsa azureuser@<machine_ip>

## Lab2
cd lab2/terraform\
terraform init\
terraform plan -var-file=vars/config1.tfvars\
terraform apply -var-file=vars/config1.tfvars

### ssh
[ ~/wus-24z-laboratorium/lab2/terraform ]$ ssh -i generated_private_key.pem Admin123@<machine_ip>

# WUS-24Z-laboratorium
https://gitlab-stud.elka.pw.edu.pl/mdobrow2/wus-24z-laboratorium.git

## Lab2
cd lab2/terraform\
terraform init\
terraform plan -var-file=vars/config1.tfvars\
terraform apply -var-file=vars/config1.tfvars

### ssh
[ ~/wus-24z-laboratorium/lab2/terraform ]$ ssh -i generated_private_key.pem Admin123@13.95.126.177

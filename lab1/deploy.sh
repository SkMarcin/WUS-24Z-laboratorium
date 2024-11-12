#!/bin/bash

# Ensure jq is installed on your system for JSON parsing

if [ -z "$1" ]; then
  echo "Usage: $0 <json-file>"
  exit 1
fi

JSON_FILE=$1

resource_group_name=$(jq -r '.resource_group_name' "$JSON_FILE")
echo "Creating resource group: $resource_group_name"
az group create --location westeurope --name "$resource_group_name"

echo "Creating virtual network"
az network vnet create --name network --resource-group "$resource_group_name" --address-prefix 10.0.0.0/16

echo "Creating network security groups and rules"
network_security_groups=$(jq -r '.network_security_groups | keys[]' "$JSON_FILE")
for group in $network_security_groups; do
  nsg_name=$(jq -r ".network_security_groups[\"$group\"].name" "$JSON_FILE")
  rule=$(jq ".network_security_groups[\"$group\"].rule" "$JSON_FILE")

  echo "Creating network security group: $nsg_name"
  az network nsg create --resource-group "$resource_group_name" --name "$nsg_name"

  rule_name=$(echo "$rule" | jq -r '.name')
  rule_protocol=$(echo "$rule" | jq -r '.protocol')
  rule_priority=$(echo "$rule" | jq -r '.priority')
  rule_src_addr_pref=$(echo "$rule" | jq -r '.src_addr_pref')
  rule_src_port_ranges=$(echo "$rule" | jq -r '.src_port_ranges')
  rule_dst_addr_pref=$(echo "$rule" | jq -r '.dst_addr_pref')
  rule_dst_port_ranges=$(echo "$rule" | jq -r '.dst_port_ranges')
  rule_access=$(echo "$rule" | jq -r '.access')

  az network nsg rule create \
    --resource-group "$resource_group_name" \
    --nsg-name "$nsg_name" \
    --name "$rule_name" \
    --protocol "$rule_protocol" \
    --priority "$rule_priority" \
    --destination-address-prefix "$rule_dst_addr_pref" \
    --destination-port-range "$rule_dst_port_ranges" \
    --source-address-prefix "$rule_src_addr_pref" \
    --source-port-range "$rule_src_port_ranges" \
    --access "$rule_access"
done

echo "Creating subnets"
subnets=$(jq -r '.subnets | keys[]' "$JSON_FILE")
for subnet in $subnets; do
  subnet_name=$(jq -r ".subnets[\"$subnet\"].name" "$JSON_FILE")
  addr_pref=$(jq -r ".subnets[\"$subnet\"].addr_pref" "$JSON_FILE")
  nsg=$(jq -r ".subnets[\"$subnet\"].nsg" "$JSON_FILE")

  echo "Creating subnet: $subnet_name"
  az network vnet subnet create \
    --resource-group "$resource_group_name" \
    --vnet-name network \
    --name "$subnet_name" \
    --address-prefix "$addr_pref" \
    --network-security-group "$nsg"
done

echo "Creating public IPs"
public_ips=$(jq -r '.public_ips[]' "$JSON_FILE")
for public_ip in $public_ips; do
  echo "Creating public IP: $public_ip"
  az network public-ip create --resource-group "$resource_group_name" --name "$public_ip"
done

echo "Creating VMs"
vms=$(jq -r '.vms | keys[]' "$JSON_FILE")
for vm in $vms; do
  subnet=$(jq -r ".vms[\"$vm\"].subnet" "$JSON_FILE")
  nsg=$(jq -r ".vms[\"$vm\"].nsg" "$JSON_FILE")
  public_ip=$(jq -r ".vms[\"$vm\"].public_ip" "$JSON_FILE")
  vm_name=$(jq -r ".vms[\"$vm\"].name" "$JSON_FILE")
  private_ip=$(jq -r ".vms[\"$vm\"].IP" "$JSON_FILE")

  echo "Creating VM: $vm_name"
  az vm create \
    --name "$vm_name" \
    --resource-group "$resource_group_name" \
    --image Canonical:ubuntu-24_04-lts:server:latest \
    --generate-ssh-keys \
    --vnet-name network \
    --subnet "$subnet" \
    --nsg "$nsg" \
    --private-ip-address "$private_ip" \
    --public-ip-address "$public_ip"
done

echo "Deploying components"
components=$(jq -r '.components | keys[]' "$JSON_FILE")
for component in $components; do
  type=$(jq -r ".components[\"$component\"].type" "$JSON_FILE")
  vm_name=$(jq -r ".components[\"$component\"].vm_name" "$JSON_FILE")
  port=$(jq -r ".components[\"$component\"].port" "$JSON_FILE")

  echo "Deploying component $component of type $type on VM $vm_name"

  if [ "$type" == "db_master" ]; then
    az vm run-command invoke \
      --command-id RunShellScript \
      --name "$vm_name" \
      --resource-group "$resource_group_name" \
      --scripts "@./db_master.sh" \
      --parameters "$port"

  elif [ "$type" == "backend" ]; then
    db_component=$(jq -r ".components[\"$component\"].related[0].component" "$JSON_FILE")
    db_vm=$(jq -r ".components[\"$component\"].related[0].vm" "$JSON_FILE")
    db_ip=$(jq -r ".vms[\"$db_vm\"].IP" "$JSON_FILE")
    db_port=$(jq -r ".components[\"$db_component\"].port" "$JSON_FILE")

    az vm run-command invoke \
      --command-id RunShellScript \
      --name "$vm_name" \
      --resource-group "$resource_group_name" \
      --scripts "@./backend.sh" \
      --parameters "$port" "$db_ip" "$db_port"

  elif [ "$type" == "frontend" ]; then
    backend_component=$(jq -r ".components[\"$component\"].related[0].component" "$JSON_FILE")
    backend_ip=$(az network public-ip show --resource-group "$resource_group_name" --name "backend_ip" --query "ipAddress" --output tsv)
    backend_port=$(jq -r ".components[\"$backend_component\"].port" "$JSON_FILE")

    az vm run-command invoke \
      --command-id RunShellScript \
      --name "$vm_name" \
      --resource-group "$resource_group_name" \
      --scripts "@./frontend.sh" \
      --parameters "$backend_ip" "$backend_port" "$port"
    
  elif [ "$type" == "db_slave" ]; then
      db_master_component=$(jq -r ".components[\"$component\"].related[0].component" "$JSON_FILE")
      db_master_vm=$(jq -r ".components[\"$component\"].related[0].vm" "$JSON_FILE")

      db_master_port=$(jq -r ".components[\"$db_master_component\"].port" "$JSON_FILE")
      db_master_ip=$(jq -r ".vms[\"$db_master_vm\"].IP" "$JSON_FILE")

      az vm run-command invoke \
          --command-id RunShellScript \
          --name "$vm_name" \
          --resource-group "$resource_group_name" \
          --scripts "@./db_slave.sh" \
          --parameters "$port" "$db_master_ip" "$db_master_port"
  fi
done

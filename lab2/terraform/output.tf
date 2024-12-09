data "azurerm_public_ip" "ansible_public_ip" {
  name                  = "frontend_ip"
  resource_group_name   = "config-1-rg"
}

output "ansible_public_ip" {
  value = data.azurerm_public_ip.ansible_public_ip.ip_address
}
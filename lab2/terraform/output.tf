data "azurerm_public_ip" "ansible_public_ip" {
  name                  = "frontend_ip"
  resource_group_name   = "config-1-rg"

  depends_on = [
    azurerm_public_ip.public_ip["frontend_ip"]
  ]
}

output "ansible_public_ip" {
  value = data.azurerm_public_ip.ansible_public_ip.ip_address
}
data "azurerm_public_ip" "ansible_public_ip" {
  name                  = "frontend_ip"
  resource_group_name   = azurerm_resource_group.rg.name

  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]
}

output "ansible_public_ip" {
  value = data.azurerm_public_ip.ansible_public_ip.ip_address
}
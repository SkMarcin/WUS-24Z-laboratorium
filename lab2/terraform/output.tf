output "ansible_public_ip" {
  value = azurerm_public_ip.public_ip[sort(keys(azurerm_public_ip.public_ip))[1]].ip_address
}
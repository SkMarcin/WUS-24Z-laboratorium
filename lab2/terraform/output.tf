output "ansible_public_ip" {
  value = azurerm_public_ip.public_ip[sort(keys(azurerm_public_ip.public_ip))[1]].ip_address
  depends_on = [azurerm_public_ip.public_ip] # Ensure dependency
}
output "ansible_public_ip" {
  value = azurerm_public_ip.frontend_public_ip.ip_address
}
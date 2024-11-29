resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_network_security_group" "nsg" {
  for_each = var.network_security_groups

  name                = each.value.name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = each.value.rule_name
    protocol                   = each.value.protocol
    priority                   = each.value.priority
    destination_address_prefix = each.value.dst_addr
    destination_port_range     = each.value.dst_port
    source_address_prefix      = each.value.src_addr
    source_port_range          = each.value.src_port
    access                     = each.value.access
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "config-1-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value.addr_pref]
}

resource "azurerm_public_ip" "public_ip" {
  for_each = { for ip in var.public_ips : ip => ip }
  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "${each.value.name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.value.subnet].id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip

    public_ip_address_id = each.value.public_ip != "" ? azurerm_public_ip.public_ip[each.value.public_ip].id : null
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vms

  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_DS1_v2"
  admin_username      = "Admin123"
  admin_password      = "Admin123"

  os_disk {
    name              = "${each.value.name}-osdisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  source_image_reference {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "24.04-LTS"
  version   = "latest"
}
}

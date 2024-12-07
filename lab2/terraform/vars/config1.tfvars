resource_group_name = "config-1-rg"

network_security_groups = {
  nsg1_db = {
    name      = "nsg-1-db"
    rule_name = "nsg-db"
    direction = "Inbound"
    protocol  = "Tcp"
    priority  = 1000
    dst_addr  = "*"
    dst_port  = "3306"
    src_addr  = "10.0.0.0/16"
    src_port  = "*"
    access    = "Allow"
  }
  nsg2_backend = {
    name      = "nsg-2-backend"
    rule_name = "nsg-backend"
    direction = "Inbound"
    protocol  = "Tcp"
    priority  = 1000
    dst_addr  = "*"
    dst_port  = "8001"
    src_addr  = "*"
    src_port  = "*"
    access    = "Allow"
  }
  nsg3_frontend = {
    name      = "nsg-3-frontend"
    rule_name = "nsg-frontend"
    direction = "Inbound"
    protocol  = "Tcp"
    priority  = 1000
    dst_addr  = "*"
    dst_port  = "8000"
    src_addr  = "*"
    src_port  = "*"
    access    = "Allow"
  }
}

subnets = {
  subnet1_db = {
    name       = "subnet-1-db"
    addr_pref  = "10.0.1.0/24"
    nsg        = "nsg1_db"
  }
  subnet2_backend = {
    name       = "subnet-2-backend"
    addr_pref  = "10.0.2.0/24"
    nsg        = "nsg2_backend"
  }
  subnet3_frontend = {
    name       = "subnet-3-frontend"
    addr_pref  = "10.0.3.0/24"
    nsg        = "nsg3_frontend"
  }
}

public_ips = ["backend_ip", "frontend_ip"]

vms = {
  db_master = {
    subnet    = "subnet1_db"
    nsg       = "nsg-1-db"
    public_ip = ""
    name      = "vm-1-db-master"
    ip        = "10.0.1.20"
  }
  backend = {
    subnet    = "subnet2_backend"
    nsg       = "nsg-2-backend"
    public_ip = "backend_ip"
    name      = "vm-2-backend"
    ip        = "10.0.2.20"
  }
  frontend = {
    subnet    = "subnet3_frontend"
    nsg       = "nsg-3-frontend"
    public_ip = "frontend_ip"
    name      = "vm-3-frontend"
    ip        = "10.0.3.20"
  }
}


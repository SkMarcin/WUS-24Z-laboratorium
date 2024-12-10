resource_group_name = "config-3-rg"

network_security_groups = {
  nsg1_db = {
    name  = "nsg-1-db"
  }
  nsg2_backend = {
    name  = "nsg-2-backend"
  }
  nsg3_frontend = {
    name  = "nsg-3-frontend"
  }
}

network_security_rule = {
  ssh_rule_db = {
    rule_name  = "ssh-rule-db"
    direction  = "Inbound"
    protocol   = "Tcp"
    priority   = 1000
    dst_addr   = "*"
    dst_port   = "22"
    src_addr   = "10.0.0.0/16"
    src_port   = "*"
    access     = "Allow"
    nsg        = "nsg1_db"
  }
  db_rule = {
    rule_name  = "db-rule"
    direction  = "Inbound"
    protocol   = "Tcp"
    priority   = 1001
    dst_addr   = "*"
    dst_port   = "3306-3307"
    src_addr   = "10.0.0.0/16"
    src_port   = "*"
    access     = "Allow"
    nsg        = "nsg1_db"
  }
  ssh_rule_backend = {
    rule_name  = "ssh-rule-backend"
    direction  = "Inbound"
    protocol   = "Tcp"
    priority   = 1000
    dst_addr   = "*"
    dst_port   = "22"
    src_addr   = "*"
    src_port   = "*"
    access     = "Allow"
    nsg        = "nsg2_backend"
  }
  backend_rule = {
    rule_name  = "backend-rule"
    direction  = "Inbound"
    protocol   = "Tcp"
    priority   = 1001
    dst_addr   = "*"
    dst_port   = "8010"
    src_addr   = "*"
    src_port   = "*"
    access     = "Allow"
    nsg        = "nsg2_backend"
  }
  ssh_rule_frontend = {
    rule_name  = "ssh-rule-frontend"
    direction  = "Inbound"
    protocol   = "Tcp"
    priority   = 1000
    dst_addr   = "*"
    dst_port   = "22"
    src_addr   = "*"
    src_port   = "*"
    access     = "Allow"
    nsg        = "nsg3_frontend"
  }
  frontend_rule = {
    rule_name  = "frontend-rule"
    direction  = "Inbound"
    protocol   = "Tcp"
    priority   = 1001
    dst_addr   = "*"
    dst_port   = "8000"
    src_addr   = "*"
    src_port   = "*"
    access     = "Allow"
    nsg        = "nsg3_frontend"
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
  db_slave = {
    subnet    = "subnet1_db"
    nsg       = "nsg-1-db"
    public_ip = ""
    name      = "vm-1-db-slave"
    ip        = "10.0.1.21"
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


variable "resource_group_name" {
  default = "config-1-rg"
}

variable "network_security_groups" {
  type = map(object({
    name       = string
    rule_name  = string
    protocol   = string
    priority   = number
    dst_addr   = string
    dst_port   = string
    src_addr   = string
    src_port   = string
    access     = string
  }))
  default = {
    nsg1_db = {
      name      = "nsg-1-db"
      rule_name = "nsg-db"
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
      protocol  = "Tcp"
      priority  = 1000
      dst_addr  = "*"
      dst_port  = "8000"
      src_addr  = "*"
      src_port  = "*"
      access    = "Allow"
    }
  }
}

variable "subnets" {
  type = map(object({
    name       = string
    addr_pref  = string
    nsg        = string
  }))
  default = {
    subnet1_db = {
      name       = "subnet-1-db"
      addr_pref  = "10.0.1.0/24"
      nsg        = "nsg-1-db"
    }
    subnet2_backend = {
      name       = "subnet-2-backend"
      addr_pref  = "10.0.2.0/24"
      nsg        = "nsg-2-backend"
    }
    subnet3_frontend = {
      name       = "subnet-3-frontend"
      addr_pref  = "10.0.3.0/24"
      nsg        = "nsg-3-frontend"
    }
  }
}

variable "vms" {
  type = map(object({
    subnet    = string
    nsg       = string
    public_ip = string
    name      = string
    ip        = string
  }))
  default = {
    db_master = {
      subnet    = "subnet-1-db"
      nsg       = "nsg-1-db"
      public_ip = ""
      name      = "vm-1-db-master"
      ip        = "10.0.1.20"
    }
    backend = {
      subnet    = "subnet-2-backend"
      nsg       = "nsg-2-backend"
      public_ip = "backend_ip"
      name      = "vm-2-backend"
      ip        = "10.0.2.20"
    }
    frontend = {
      subnet    = "subnet-3-frontend"
      nsg       = "nsg-3-frontend"
      public_ip = "frontend_ip"
      name      = "vm-3-frontend"
      ip        = "10.0.3.20"
    }
  }
}

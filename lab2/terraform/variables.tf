variable "location" {
  type        = string
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type = string
}

variable "network_security_groups" {
  type = map(object({
    name       = string
  }))
}

variable  "network_security_rules" {
  type = map(object({
    rule_name  = string
    direction  = string
    protocol   = string
    priority   = number
    dst_addr   = string
    dst_port   = string
    src_addr   = string
    src_port   = string
    access     = string
    nsg        = string
  }))
}

variable "subnets" {
  type = map(object({
    name       = string
    addr_pref  = string
    nsg        = string
  }))
}

variable "public_ips" {
  type    = list(string)
}

variable "vms" {
  type = map(object({
    subnet    = string
    nsg       = string
    public_ip = string
    name      = string
    ip        = string
  }))
}


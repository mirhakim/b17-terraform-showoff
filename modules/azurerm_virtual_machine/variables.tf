variable "nic_name" {
  type = string
}
variable "location" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "vm_name" {
  type = string
}
variable "vm_size" {
  type = string
}

variable "image_publisher" {
  type = string
}
variable "image_offer" {
  type = string
}
variable "image_sku" {
  type = string
}
variable "image_version" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "secret_username" {
  type = string
}

variable "secret_password" {
  type = string
}

variable "subnet_id" {}
variable "public_ip_id" {}

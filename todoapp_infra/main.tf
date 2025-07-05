module "resource_group" {
  source = "../modules/azurerm_resource_group"
  resource_group_name = "rg-todoapp"
  resource_group_location = "central india"
}

module "keyvault" {
  depends_on = [ module.resource_group ]
  source = "../modules/azurerm_key_vault"
  keyvault_name = "TodoApp-keyvault230"
  resource_group_name = "rg-todoapp"
  location = "central india"
}

module "frontend_nsg" {
  depends_on = [ module.resource_group ]
  source = "../modules/azurerm_network_security_group"
  nsg_name = "nsg-frontend"
  location = "central india"
  resource_group_name = "rg-todoapp"
  
}

module "backend_nsg" {
  depends_on = [ module.resource_group ]
  source = "../modules/azurerm_network_security_group"
  nsg_name = "nsg-backend"
  location = "central india"
  resource_group_name = "rg-todoapp"
  
}
module "virtual_network" {
    depends_on = [ module.resource_group ]
  source = "../modules/azurerm_virtual_network"
  virtual_network_name = "vnet-todoapp"
  virtual_network_location = "central india"
  resource_group_name = "rg-todoapp"
  address_space = [ "10.0.0.0/16" ]
}
module "frontend_subnet" {
    depends_on = [ module.virtual_network ]
  source = "../modules/azurerm_subnet"
  resource_group_name = "rg-todoapp"
  virtual_network_name = "vnet-todoapp"
  subnet_name = "frontend-subnet"
  address_prefixes = [ "10.0.1.0/24" ]
  network_security_group_id = module.frontend_nsg.nsg_id
  }

module "backend_subnet" {
    depends_on = [ module.virtual_network ]
  source = "../modules/azurerm_subnet"
  resource_group_name = "rg-todoapp"
  virtual_network_name = "vnet-todoapp"
  subnet_name = "backend-subnet"
  address_prefixes = [ "10.0.2.0/24" ]
  network_security_group_id = module.backend_nsg.nsg_id
}

module "public_ip_frontend" {
  depends_on = [ module.resource_group ]
  source = "../modules/azurerm_public_ip"
  public_ip_name = "pip-todoapp-frontend"
  resource_group_name = "rg-todoapp"
  location = "central india"
  allocation_method = "Static"
}

module "public_ip_backend" {
  depends_on = [ module.resource_group ]
  source = "../modules/azurerm_public_ip"
  public_ip_name = "pip-todoapp-backend"
  resource_group_name = "rg-todoapp"
  location = "central india"
  allocation_method = "Static"
}

module "frontend_vm" {
  depends_on = [ module.virtual_network, module.frontend_subnet, module.keyvault ]
  source = "../modules/azurerm_virtual_machine"
  resource_group_name = "rg-todoapp"
  location = "central india"
  vm_name = "vm-frontend"
  vm_size = "Standard_B1s"
  secret_username = "fronend-userid"
  secret_password = "frontend-password"
  keyvault_name = "TodoApp-keyvault230"
  image_publisher = "Canonical"
  image_offer = "UbuntuServer"
  image_sku = "18.04-LTS"
  image_version = "latest"
  nic_name = "nic-vm-frontend"
 virtual_network_name = "vnet-todoapp"
 subnet_id = module.frontend_subnet.subnet_id
 public_ip_id = module.public_ip_frontend.public_ip_id

}

module "backend_vm" {
  depends_on = [ module.backend_subnet, module.virtual_network, module.keyvault ]
  source = "../modules/azurerm_virtual_machine"
  resource_group_name = "rg-todoapp"
  location = "central india"
  vm_name = "vm-backend"
  vm_size = "Standard_B1s"
  secret_username = "backend-username"
  secret_password = "backend-password"
  keyvault_name = "TodoApp-keyvault230"
  image_publisher = "Canonical"
  image_offer = "0001-com-ubuntu-server-focal"
  image_sku = "20_04-lts"
  image_version = "latest"
  nic_name = "nic-vm-backend"
  virtual_network_name = "vnet-todoapp"
  subnet_id = module.backend_subnet.subnet_id
  public_ip_id  = module.public_ip_backend.public_ip_id
}


resource "null_resource" "install_nginx_frontend" {
  depends_on = [module.frontend_vm, module.public_ip_frontend]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      host        = module.public_ip_frontend.public_ip     # ← Output from public_ip module
      user        = module.frontend_vm.secret_username # ← Output from VM module
      password    = module.frontend_vm.secret_password   # ← Since  using password authentication
    }
  }
}



module "sql_server" {
  depends_on = [ module.resource_group, module.keyvault ]
  source = "../modules/azurerm_sql_server"
  sql_server_name = "todosqlserver203"
  resource_group_name = "rg-todoapp"
  location = "central india"
  secret_username = "sqladmin-username"
  secret_password = "sqladmin-password"
  keyvault_name = "TodoApp-keyvault230"
}

module "sql_database" {
  depends_on = [ module.sql_server ]
  source = "../modules/azurerm_sql_database"
  sql_database_name = "tododb"
  server_id = module.sql_server.sql_server_id
  
}





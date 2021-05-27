resource "azurerm_resource_group" "contrall" {
    name     = "contrallResourceGroup"
    location = "westeurope"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "basic-network"
  resource_group_name = azurerm_resource_group.contrall.name
  location            = azurerm_resource_group.contrall.location
  address_space       = ["10.0.0.0/24"]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = azurerm_resource_group.contrall.location
    resource_group_name = azurerm_resource_group.contrall.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.contrall.name
    virtual_network_name = azurerm_virtual_network.example.name
    address_prefixes       = ["10.0.0.0/26"]
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" {
  value = tls_private_key.example_ssh.private_key_pem
  sensitive   = true
}


resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.contrall.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.contrall.name
    location                    = azurerm_resource_group.contrall.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = azurerm_resource_group.contrall.location
    resource_group_name          = azurerm_resource_group.contrall.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}


resource "azurerm_network_interface" "myterraformnic" {
    name                        = "myNIC"
    location                    = azurerm_resource_group.contrall.location
    resource_group_name         = azurerm_resource_group.contrall.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}


# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}



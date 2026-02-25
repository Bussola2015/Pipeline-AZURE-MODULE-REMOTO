
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${chomp(data.http.my_ip.response_body)}/32" ## Pegamos o corpo da resposta HTTP e adicionamos o prefixo /32
    destination_address_prefix = "*"
  }

  # NOVA REGRA: Liberar HTTP para o Nginx
  security_rule {
    name                       = "HTTP"
    priority                   = 110 # Prioridade logo após o SSH
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80" # Porta do Nginx
    source_address_prefix      = "*"  # Permitir acesso de qualquer IP (Público)  ----  pode ser para teste somente o meu: "${chomp(data.http.my_ip.response_body)}/32"
    destination_address_prefix = "*"
  }

  tags = local.common_tags

}

resource "azurerm_subnet_network_security_group_association" "snsga" {
  subnet_id                 = module.network.vnet_subnets[0]
  network_security_group_id = azurerm_network_security_group.nsg.id
}


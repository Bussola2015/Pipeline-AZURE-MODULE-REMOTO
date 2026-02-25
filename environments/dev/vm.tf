# 1. Geração da Chave Privada RSA (em memória)
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
#https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key

# 2. Salvando a chave privada localmente (para uso manual se necessário)
# Note que no Azure não usamos um "Resource" de Key Pair separado como na AWS, 
# a chave é injetada diretamente na criação da VM.
resource "local_file" "private_key" {
  content         = tls_private_key.rsa_key.private_key_pem
  filename        = var.private_key_path
  file_permission = "0400"
}
#https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file

resource "azurerm_resource_group" "resource_group" {
  name     = "rg-modulos-remotos-${var.environment}"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip-${var.environment}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  allocation_method   = "Static" # professor manteve como Dynamic, mas Dymanic gera error 
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "network_interface" {
  name                = "nic-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "ipconfig-${var.environment}"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = local.common_tags
}

# Associo para não ficar solto, network_interface com o NSG
resource "azurerm_network_interface_security_group_association" "nisga" {
  network_interface_id      = azurerm_network_interface.network_interface.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_linux_virtual_machine" "vm" {

  depends_on = [
    azurerm_network_interface_security_group_association.nisga
  ]

  name                = "vm-${var.environment}"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  size                = "Standard_L2as_v4" #Standard_B1s  
  admin_username      = "terraformuser"
  network_interface_ids = [
    azurerm_network_interface.network_interface.id,
  ]
  # Automação da Chave: Injetando a chave pública gerada pelo TLS
  admin_ssh_key {
    username   = "terraformuser" #posso usar azurerm_linux_virtual_machine.vm.admin_username aqui? --- professor manteve como terraformuser --- Resposta: Não, isso causará um erro de Ciclo de Dependência (Cycle Error) ou uma referência circular, tipo deadlock, porque o recurso da máquina virtual ainda não foi criado e, portanto, não tem um valor para admin_username no momento em que o Terraform está processando a configuração. O Terraform precisa conhecer o valor de admin_username para criar a máquina virtual, mas se você tentar referenciá-lo dentro do próprio recurso, ele não estará disponível, resultando em um erro. Portanto, é necessário usar um valor fixo ou uma variável que seja conhecida antes da criação do recurso.
    public_key = tls_private_key.rsa_key.public_key_openssh
    #public_key = file("./azure-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  #check no portal antes de usar a imagem, tem que ser uma imagem que exista na região escolhida ou usar um data source
  source_image_reference {
    publisher = "debian"
    offer     = "debian-13"
    sku       = "13-gen2"
    version   = "latest" #não boa pratica usar latest, mas para fins de teste e aprendizado pode ser usado, só cuidado para não usar em produção
  }

  tags = local.common_tags

}



terraform {
  #bloco terraform nao permite variaveis ou recursos em seu interior
  required_version = ">= 1.1.0"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "4.58.0"
      version = ">= 3.0.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform"
    storage_account_name = "stjuniorbussolastate"
    container_name       = "remote-state"
    key                  = "azure-vm-modulos-remotos-pipeline/terraform.tfstate"
    # O Lock aqui é automático via Blob Lease! (Nativo)
  }

}

provider "azurerm" {
  features {}
}

module "network" {
  source  = "Azure/network/azurerm"
  version = "5.3.0"
  # insert the 2 required variables here

  resource_group_name = azurerm_resource_group.resource_group.name
  use_for_each        = true
  # Abaixo são as opções não obrigatórias
  resource_group_location = var.location
  subnet_names            = ["subnet-${var.environment}"]
  tags                    = local.common_tags
  vnet_name               = "vnet-${var.environment}"

  # GARANTIA DE ORDEM: Só cria a rede após o RG estar pronto
  #depends_on = [azurerm_resource_group.resource_group]
}


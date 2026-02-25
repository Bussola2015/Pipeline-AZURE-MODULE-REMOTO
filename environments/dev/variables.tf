variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  default     = "Brazil South"

}

variable "private_key_path" {
  description = "Caminho local para a chave privada SSH (.pem ou .rsa)"
  type        = string
  default     = "./azure-key.pem" # Opcional: define um caminho padrão
}

variable "environment" {
  description = "Ambiente para nomear recursos (ex: dev, prod)"
  type        = string
  default     = "dev" # Opcional: define um ambiente padrão
}
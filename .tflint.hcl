plugin "azurerm" {
    enabled = true
    version = "0.27.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Dica: Adicione este bloco para evitar avisos sobre versões do TFLint
# config {
#     format = "compact"
#     module = true
#     force = false
# }
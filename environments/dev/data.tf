# Consultar o IP público do usuário para configurar regras de NSG ou outras necessidades de rede
# data "http" "my_ip" {
#   url = "https://ifconfig.me/ip"
# }

data "http" "my_ip" {
  # Esta URL da OpenDNS força o retorno apenas do IPv4
  url = "https://ipv4.icanhazip.com"
}
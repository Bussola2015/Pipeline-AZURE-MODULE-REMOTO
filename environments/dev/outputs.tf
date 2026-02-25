output "vm-ip" {
  description = "The public IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.public_ip_address

}

output "ssh_command" {
  description = "Comando pronto para acessar a VM no Azure"
  # No Azure, o usuário padrão geralmente é definido no bloco admin_username no bloco da vm
  #value = "ssh -i ${var.private_key_path} terraformuser@${azurerm_public_ip.public_ip.ip_address}"  #está correto sim também, mas pelo local_file é mais profissional
  value = "ssh -i ${local_file.private_key.filename} terraformuser@${azurerm_public_ip.public_ip.ip_address}"
}


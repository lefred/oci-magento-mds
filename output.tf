output "magento_public_ip" {
  value = module.web.public_ip
}

output "magento_db_user" {
  value = var.magento_name
}

output "magento_db_password" {
  value = var.magento_password
}

output "mds_instance_ip" {
  value = module.mds-instance.private_ip
}

output "opendistro_private_ip" {
  value = module.opendistro.private_ip
}

output "ssh_private_key" {
  value = local.private_key_to_show
}

output "magento_admin_login" {
  value = var.magento_admin_login
}

output "magento_admin_password" {
  value = var.magento_admin_password
}


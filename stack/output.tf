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

output "instance_ssh_keys" {
  value = local.private_key_to_show
}

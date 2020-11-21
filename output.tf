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

output "elastic_private_ip" {
  value = module.elastic.private_ip
}


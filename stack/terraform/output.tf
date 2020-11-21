output "magento_public_ip" {
  value = "${module.magento.public_ip}"
}

output "magento_db_user" {
  value = var.magento_name
}

output "magento_db_password" {
  value = var.magento_password
}

output "mds_instance_ip" {
  value = "${module.mds-instance.private_ip}"
}

output "elastic_public_ip" {
  value = "${module.elastic.public_ip}"
}

output "elastic_private_ip" {
  value = "${module.elastic.private_ip}"
}

output "instance_ssh_keys" {
  value       = tls_private_key.public_private_key_pair.private_key_pem
  description = "Please copy and save the private key to ssh in compute instance"
}

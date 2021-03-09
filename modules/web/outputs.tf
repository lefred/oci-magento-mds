output "id" {
  value = oci_core_instance.Magento.*.id
}

output "public_ip" {
  value = join(", ", oci_core_instance.Magento.*.public_ip)
}

output "magento_user_name" {
  value = var.magento_name
}

output "magento_schema_name" {
  value = var.magento_schema
}

output "magento_host_name" {
  value = oci_core_instance.Magento.*.display_name
}

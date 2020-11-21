output "id" {
  value = oci_core_instance.Magento.id
}

output "public_ip" {
  value = oci_core_instance.Magento.public_ip
}

output "magento_host_name" {
  value = oci_core_instance.Magento.display_name
}

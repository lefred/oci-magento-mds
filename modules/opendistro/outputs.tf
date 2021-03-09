output "id" {
  value = oci_core_instance.OpenDistro.id
}

output "private_ip" {
  value = oci_core_instance.OpenDistro.private_ip
}

output "opendistro_host_name" {
  value = oci_core_instance.OpenDistro.display_name
}

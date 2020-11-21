output "id" {
  value = oci_core_instance.ElasticSearch.id
}

output "private_ip" {
  value = oci_core_instance.ElasticSearch.private_ip
}

output "elasticsearch_host_name" {
  value = oci_core_instance.ElasticSearch.display_name
}

data "oci_core_images" "images_for_shape" {
    compartment_id = var.compartment_ocid
    operating_system = "Oracle Linux"
    operating_system_version = "8"
    shape = var.node_shape
    sort_by = "TIMECREATED"
    sort_order = "DESC"
}

data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "ad_names" {
  count    = length(data.oci_identity_availability_domains.ad.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")
}


data "oci_mysql_mysql_configurations" "shape" {
    compartment_id = var.compartment_ocid
    type = ["DEFAULT"]
    shape_name = var.mysql_shape
}


resource "oci_core_virtual_network" "mysqlvcn" {
  cidr_block = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name = var.vcn
  dns_label = "mysqlvcn"
}


resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name = "internet_gateway"
  vcn_id = oci_core_virtual_network.mysqlvcn.id
}


resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mysqlvcn.id
  display_name   = "nat_gateway"
}


resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  display_name = "RouteTableForMySQLPublic"
  route_rules {
    cidr_block = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}


resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.mysqlvcn.id
  display_name   = "RouteTableForMySQLPrivate"
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_ocid
  display_name = "Allow Public SSH Connections to Magento"
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "private_security_list_elastic" {
  compartment_id = var.compartment_ocid
  display_name = "Allow ElasticSearch"
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  egress_security_rules {
    destination = "10.0.1.0/24"
    protocol = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 9200
      min = 9200
    }
    protocol = "6"
    source   = "10.0.0.0/24"
  }
}

resource "oci_core_security_list" "public_security_list_http" {
  compartment_id = var.compartment_ocid
  display_name = "Allow HTTP(S) to Magento"
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_ocid
  display_name   = "Private"
  vcn_id         = oci_core_virtual_network.mysqlvcn.id

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules  {
    protocol = "1"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 3306
      min = 3306
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
  ingress_security_rules  {
    tcp_options  {
      max = 33061
      min = 33060
    }
    protocol = "6"
    source   = var.vcn_cidr
  }
}

resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
}

resource "oci_core_subnet" "public" {
  cidr_block = cidrsubnet(var.vcn_cidr, 8, 0)
  display_name = "mysql_public_subnet"
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.mysqlvcn.id
  route_table_id = oci_core_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.public_security_list.id, oci_core_security_list.public_security_list_http.id]
  dhcp_options_id = oci_core_virtual_network.mysqlvcn.default_dhcp_options_id
  dns_label = "mysqlpub"
}

resource "oci_core_subnet" "private" {
  cidr_block                 = cidrsubnet(var.vcn_cidr, 8, 1)
  display_name               = "mysql_private_subnet"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.mysqlvcn.id
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.private_security_list.id,  oci_core_security_list.private_security_list_elastic.id]
  dhcp_options_id            = oci_core_virtual_network.mysqlvcn.default_dhcp_options_id
  prohibit_public_ip_on_vnic = "true"
  dns_label                  = "mysqlpriv"
}

module "mds-instance" {
    source         = "./modules/mds-instance"
    admin_password = var.admin_password
    admin_username = var.admin_username
    availability_domain = data.template_file.ad_names.*.rendered[0]
    configuration_id = data.oci_mysql_mysql_configurations.shape.configurations[0].id
    compartment_ocid = var.compartment_ocid
    subnet_id = oci_core_subnet.private.id
    display_name = "MySQLInstance"
}

module "elastic" {
  source                = "./modules/elastic"
  availability_domain   = data.template_file.ad_names.*.rendered[0]
  display_name          =  "ElasticSearch"
  compartment_ocid      = var.compartment_ocid
  image_id              = var.node_image_id == "" ? data.oci_core_images.images_for_shape.images[0].id : var.node_image_id
  shape                 = var.node_shape
  label_prefix          = var.label_prefix
  subnet_id             = oci_core_subnet.private.id
  ssh_authorized_keys   = var.ssh_authorized_keys_path == "" ? tls_private_key.public_private_key_pair.public_key_openssh : file(var.ssh_authorized_keys_path)
  ssh_private_key       = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file(var.ssh_private_key_path)
  bastion_private_key   = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file(var.ssh_private_key_path)
  bastion_public_key    = var.ssh_authorized_keys_path == "" ? tls_private_key.public_private_key_pair.public_key_openssh : file(var.ssh_authorized_keys_path)
  bastion_ip            = var.bastion_host == null ? module.web.public_ip : var.bastion_host
}

module "web" {
  source                = "./modules/web"
  availability_domain   = data.template_file.ad_names.*.rendered[0]
  display_name          =  "Magento"
  compartment_ocid      = var.compartment_ocid
  image_id              = var.node_image_id == "" ? data.oci_core_images.images_for_shape.images[0].id : var.node_image_id
  shape                 = var.node_shape
  label_prefix          = var.label_prefix
  subnet_id             = oci_core_subnet.public.id
  ssh_authorized_keys   = var.ssh_authorized_keys_path == "" ? tls_private_key.public_private_key_pair.public_key_openssh : file(var.ssh_authorized_keys_path)
  ssh_private_key       = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file(var.ssh_private_key_path)
  mds_ip                = module.mds-instance.private_ip
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  magento_schema        = var.magento_schema
  magento_name          = var.magento_name
  magento_password      = var.magento_password
}

module "magento" {
  source                = "./modules/magento"
  ssh_authorized_keys   = var.ssh_authorized_keys_path == "" ? tls_private_key.public_private_key_pair.public_key_openssh : file(var.ssh_authorized_keys_path)
  ssh_private_key       = var.ssh_private_key_path == "" ? tls_private_key.public_private_key_pair.private_key_pem : file(var.ssh_private_key_path)
  mds_ip                = module.mds-instance.private_ip
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  magento_schema        = var.magento_schema
  magento_name          = var.magento_name
  magento_password      = var.magento_password
  elastic_ip            = module.elastic.private_ip
  web_ip                = module.web.public_ip
}

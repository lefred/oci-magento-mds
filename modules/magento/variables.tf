variable "mysql_version" {
  description = "The version of the Mysql Shell."
  default     = "8.0.22"
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "vm_user" {
  description = "The SSH user to connect to the master host."
  default     = "opc"
}

variable "magento_name" {
  description = "Magento Database User Name."
}

variable "magento_password" {
  description = "Magento Database User Password."
}

variable "magento_schema" {
  description = "Magento MySQL Schema"
}

variable "admin_username" {
    description = "Username od the MDS admin account"
}


variable "admin_password" {
    description = "Password for the admin user for MDS"
}

variable "mds_ip" {
    description = "Private IP of the MDS Instance"
}

variable "elastic_ip" {
    description = "Private IP of the ElasticSearch Instance"
}

variable "web_ip" {
  description = "IP of thei Web Instance."
  default     = ""
}

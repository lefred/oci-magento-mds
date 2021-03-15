## DATASOURCE
# Init Script Files

data "template_file" "install_magento" {
  template = file("${path.module}/scripts/deploy_magento.sh")

  vars = {
    magento_name            = var.magento_name
    magento_password        = var.magento_password
    magento_schema          = var.magento_schema
    mds_ip                  = var.mds_ip
    opendistro_ip           = var.opendistro_ip
    magento_admin_login     = var.magento_admin_login
    magento_admin_password  = var.magento_admin_password
    magento_admin_firstname = var.magento_admin_firstname
    magento_admin_lastname  = var.magento_admin_lastname
    magento_admin_email     = var.magento_admin_email
  }
}

data "template_file" "configure_local_security" {
  template = file("${path.module}/scripts/configure_local_magento_security.sh")
}

locals {
  magento_script    = "~/deploy_magento.sh"
  security_script   = "~/configure_local_magento_security.sh"
}

resource "null_resource" "MagentoDeploy" {
  count    = var.nb_of_webserver
  provisioner "file" {
    content     = data.template_file.install_magento.rendered
    destination = local.magento_script

    connection  {
      type        = "ssh"
      host        = trimspace(split(",", var.web_ip)[count.index])
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection  {
      type        = "ssh"
      host        = trimspace(split(",", var.web_ip)[count.index])
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = trimspace(split(",", var.web_ip)[count.index])
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }

    inline = [
       "chmod +x ${local.magento_script}",
       "sudo ${local.magento_script}",
       "chmod +x ${local.security_script}",
       "sudo ${local.security_script}"
    ]

   }

}
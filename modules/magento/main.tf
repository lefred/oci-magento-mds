## DATASOURCE
# Init Script Files

data "template_file" "install_magento" {
  template = file("${path.module}/scripts/install_magento.sh")

  vars = {
    magento_name     = var.magento_name
    magento_password = var.magento_password
    magento_schema   = var.magento_schema
    mds_ip           = var.mds_ip
    elastic_ip       = var.elastic_ip
  }
}

data "template_file" "configure_local_security" {
  template = file("${path.module}/scripts/configure_local_security.sh")
}

locals {
  magento_script    = "~/install_magento.sh"
  security_script   = "~/configure_local_security.sh"
}

resource "null_resource" "MagentoDeploy" {

  provisioner "file" {
    content     = data.template_file.install_magento.rendered
    destination = local.magento_script

    connection  {
      type        = "ssh"
      host        = var.web_ip
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
      host        = var.web_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = var.web_ip
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


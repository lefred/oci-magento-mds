## DATASOURCE
# Init Script Files
data "template_file" "install_opendistro" {
  template = file("${path.module}/scripts/install_opendistro.sh")

}

data "template_file" "configure_local_security" {
  template = file("${path.module}/scripts/configure_local_security.sh")
}

locals {
  opendistro_script        = "~/install_opendistro.sh"
  security_script   = "~/configure_local_security.sh"
}

resource "oci_core_instance" "OpenDistro" {
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}"
  shape               = var.shape
  availability_domain = var.availability_domain[0]

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.display_name}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = var.display_name
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    content     = data.template_file.install_opendistro.rendered
    destination = local.opendistro_script

    connection  {
      type        = "ssh"
      host        = self.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key
      bastion_host = var.bastion_ip
      bastion_user = var.vm_user
      bastion_private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection  {
      type        = "ssh"
      host        = self.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key
      bastion_host = var.bastion_ip
      bastion_user = var.vm_user
      bastion_private_key = var.ssh_private_key

    }
  }


  provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.private_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.bastion_private_key

      bastion_host = var.bastion_ip
      bastion_user = var.vm_user
      bastion_private_key = var.ssh_private_key
    }

    inline = [
       "chmod +x ${local.opendistro_script}",
       "sudo ${local.opendistro_script}",
       "chmod +x ${local.security_script}",
       "sudo ${local.security_script}"
    ]

   }

  timeouts {
    create = "10m"

  }
}

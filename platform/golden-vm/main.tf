terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
    }
  }
}

provider "oci" {
  tenancy_ocid         = "ocid1.tenancy.oc1..aaaaaaaa6vyjrctvv5ax3lzuah3ldtlnrvni6hxcqdzcfoxjw5stgu4vz32q"
  user_ocid            = "ocid1.user.oc1..aaaaaaaaihmxsgqpnkbsf5d7nmgm2xy3ctvkhf4oupu43gyti3pzfe6hpvua"
  fingerprint          = "3f:6c:1d:9b:ef:bc:03:c0:48:a6:63:d5:4c:81:74:54"
  private_key_path     = "~/.oci/robert-oci.pem"
  region               = "us-phoenix-1"
}

data "oci_core_images" "debian_golden" {
  compartment_id     = "${var.compartment_id}"
  display_name       = "${var.image_display_name}"
}

resource "oci_core_instance" "golden_vm" {
  compartment_id     = "${var.compartment_id}"
  availability_domain = "${var.availability_domain}"
  shape = "${var.instance_shape}"
  display_name = "golden-vm"
  
  create_vnic_details {
    subnet_id = "ocid1.subnet.oc1.phx.aaaaaaaaq55t2rs7mkt3pk5paxehlynvha65fpc7nukuupbxtybs55kya7wq"
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id = data.oci_core_images.debian_golden.images.0.id
  }

  metadata = { 
    ssh_authorized_keys = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJUyyIZadahSWvpaHL1pUjSmr/VXP0VBNnuHc+CSMpiJ rstarmer\nssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK3yb3nTxhMJHLyHx7lnjZANGsqCW5OBb49eR+aAzlS sdake-1\nssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJfejZLH4u9kS7qIIskMS+IhyH9nSkX4PlziPiFifzs3 sdake-3"
  }
}

output "public_ip_address" {
  value = oci_core_instance.golden_vm.public_ip
}

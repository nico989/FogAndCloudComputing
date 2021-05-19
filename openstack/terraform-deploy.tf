# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

resource "openstack_networking_network_v2" "private_network" {
  name           = "private_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "private_subnet"
  network_id = "${openstack_networking_network_v2.private_network.id}"
  cidr       = "192.168.0.0/24"
  ip_version = 4
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

resource "openstack_compute_secgroup_v2" "ssh_security_group" {
  name        = "ssh_security_group"
  description = "security group to allow ssh into instances"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_router_v2" "router_1" {
  name                = "router_1"
  admin_state_up      = true
  external_network_id = "ee53357f-34d0-42ce-b748-15e204db0705"
}

resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = "${openstack_networking_router_v2.router_1.id}"
  subnet_id = "${openstack_networking_subnet_v2.private_subnet.id}"
}

resource "openstack_compute_keypair_v2" "ssh_key_pair" {
  name       = "ssh_key_pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHPggOZgvCwFHZEM0vZHFlkYhbnMuLo63WMACPtz01Czig2eYv2LLmnt1/NhqF58Ft/N6WIKh27A558+yrdbJg70DyXPFs/72Vxk5yQaYKjQMnyQfi2tvusBAGdAHHswLTvyhtEWXbcCxuxWat75qoisXg+jVLnIKXylxXxCuT2x8ATdW9x9IN7bk2KMpXv8CklIIHMvOvhfmMvcEET7rAd3iFju3gNsjIZdlfwpFoNlDsUsuXobK2Ejb1fpHl6JtfcntVT4FNtBUDYWYGHGpLCGQGq901l5ECjOYlQvuwCnLZDJ/Lk9RMogLlUI9XGi1exx9g/rg9Ccw2yXI9ddV7"
}

resource "openstack_networking_port_v2" "port" {
  count = var.instance_num
  name               = format("%s_%02d", "port", count.index+1)
  network_id         = "${openstack_networking_network_v2.private_network.id}"
  admin_state_up     = "true"
  security_group_ids = ["${openstack_compute_secgroup_v2.ssh_security_group.id}"]
  fixed_ip {
    subnet_id  = "${openstack_networking_subnet_v2.private_subnet.id}"
    ip_address = format("%s.%02d", "192.168.0", count.index+10)
  }
}

# Create the instances
resource "openstack_compute_instance_v2" "instance" {
  count = var.instance_num
  name = format("%s_%02d", "instance", count.index+1)
  flavor_name = var.flavor_name
  image_name = var.image_name
  key_pair = "ssh_key_pair"
  user_data = file("/home/marcello.meschini/FogAndCloudComputing/openstack/setup.sh")
  network {
    port = element(openstack_networking_port_v2.port.*.id, count.index)
  }
  provisioner "file" {
    source      = "/home/marcello.meschini/FogAndCloudComputing/openstack/botnet/"
    destination = "/home/centos"
    connection {
      type     = "ssh"
      user     = "centos"
      host     = element(openstack_networking_floatingip_v2.floatip.*.address, count.index)
      private_key = file("/home/marcello.meschini/FogAndCloudComputing/openstack/id_rsa")
    }
  }
}

resource "openstack_networking_floatingip_v2" "floatip" {
  count = var.instance_num
  pool = "public"
}

resource "openstack_compute_floatingip_associate_v2" "ipassociation" {
  count = var.instance_num
  floating_ip = element(openstack_networking_floatingip_v2.floatip.*.address, count.index)
  instance_id = element(openstack_compute_instance_v2.instance.*.id, count.index)
}

# Output the fixed ips after the creation
output "instance_ips" {
    value = {
        for instance in openstack_compute_instance_v2.instance:
         instance.name => instance.access_ip_v4
    }
}

# Outputs the floating ips after the creation
output "float_ips" {
    value = {
        for association in openstack_compute_floatingip_associate_v2.ipassociation:
            association.instance_id => association.floating_ip
    }
}

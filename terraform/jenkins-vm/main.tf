terraform {

required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc01"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true
  pm_user             = "terraform@pve"
}

resource "proxmox_vm_qemu" "ubuntu_vm" {
  name        = var.vm_name
  target_node = "pve"
  memory      = 4096
  clone       = "ubuntu-24.04-template"
  full_clone  = true
  scsihw      = "virtio-scsi-pci"
  boot        = "order=scsi0"
  agent       = 1
  ipconfig0   = "ip=dhcp"
  ciuser      = "ubuntu"
  cipassword  = var.cipassword
  sshkeys     = var.ssh_public_key

  cpu {
    cores   = 2
    sockets = 1
  }


  disk {
    slot    = "scsi0"
    size    = "32G"
    type    = "disk"
    storage = "u2-ssd"
  }

  disk {
    slot    = "ide2"
    type    = "cloudinit"
    storage = "u2-ssd"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
    tag    = 10
  }
}

#Output IP address to tie to ansible playbook after
output "jenkins_ip" {
value = proxmox_vm_qemu.ubuntu_vm.default_ipv4_address
}

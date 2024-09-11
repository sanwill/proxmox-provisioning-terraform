provider "proxmox" {
  pm_api_url = "https://<PVE node IP>:8006/api2/json"
  pm_api_token_id = "PVE token ID"
  pm_api_token_secret = "PVE token secret"

}

resource "proxmox_vm_qemu" "tf-vm" {
  count = 1
  name = "test-vm" # VM name
  vmid = 1001 # ID 1001 must be free to use
  target_node = "pve-node" # PVE node name
  agent = 1  # Activate QEMU agent for this VM
  os_type = "cloud-init"  
  clone = "cloud-init-template" # VM template with "cloud-init-template" must be present at Proxmox cluster
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 8192
  scsihw = "virtio-scsi-pci"
  boot = "order=scsi0;ide0"

#net0/ipconfig0
  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  disks {
      ide {
          ide0 {
              cloudinit {
                  storage = "ssd01" # Must be present at Proxmox cluster
              }
          }
        }
      scsi {
          scsi0 {
              disk {
                  backup             = true
                  cache              = "none"
                  discard            = true
                  emulatessd         = true
                  iothread           = true
                  mbps_r_burst       = 0.0
                  mbps_r_concurrent  = 0.0
                  mbps_wr_burst      = 0.0
                  mbps_wr_concurrent = 0.0
                  replicate          = true
                  size               = 40
                  storage            = "ssd01" # Must be present at Proxmox cluster
              }
          }                  
      }
  }
  
  lifecycle {
    ignore_changes = [
      network,
      ]
  }
  
  ciuser = "<user name>" # replace with username to be used on new VM
  cipassword = "<user password>" # optional, if you prefer to use SSH public key only, comment out this
  ipconfig0 = "ip=<IP address>/<subnet>,gw=<gateway IP>"
  nameserver = "8.8.8.8" #<DNS IP>
  sshkeys = <<EOF
  <ssh key public key>
  EOF

# Remove VM finger print from known_host file
  provisioner "local-exec" {
    command = "ssh-keygen -f <known_host file> -R <VM IP/ipconfig0>"
   }

# Check connectivity to VM, this may fail if VM boot is slow
  provisioner "remote-exec" {
    connection {
      host = "<VM IP/ipconfig0>"
      type = "ssh"
      user = "<user name/ciuser>"
      timeout = "60s"
      private_key = file("<Full path of SSH private key>")
    }
    inline = [
    "hostname", "echo 'is RUNNING!'"
    ]
  }

}

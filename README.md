# VM Provisioning using Terraform in Proxmox

Terraform and cloud-init image are 2 most powerful tools to provisioin VM in my Proxmox cluster.
While Terraform would automate the provisioing process, the cloud-init image provide provide a template for the VM to be populated with user configuration.

As Terraform provider, I am using Telmate plugin. It is responsible for understanding API interactions and exposing resources. The Proxmox provider uses the Proxmox API. This provider exposes two resources: proxmox_vm_qemu and proxmox_lxc.

Check the [Terraform Telmate](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs).

## Prerequisites
- Experience is Linux
- Terraform is installed
- SSH keypairs were generated
- Create user and role in PVE for Terraform, see this [guide](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs#creating-the-proxmox-user-and-role-for-terraform).
- Next, create API tokens on PVE node. In PVE GUI, go to Datacenter - Permissions - API tokens - Add button. Select the user you just created and give and ID to the token, uncheck privilege separation (the token will have same permissions as the user). Copy the token secret to safe location then enter this token to Terraform main tf file. 
- Create VM template using a cloud-init image, for example: [Ubuntu 22.04 QCow2 cloud image](https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img).

## Steps
The [simplevm.tf](https://github.com/sanwill/proxmox-provisioning-terraform/blob/main/simplevm.tf) has example of a simple Terraform main tf file contains resource block to provision VM.

```
terraform apply
```


On a successful provisioning, provisioner "remote-exec" command will print out this follwong message

```
...
...
proxmox_vm_qemu.tf-vm[0] (remote-exec): Connected!
proxmox_vm_qemu.tf-vm[0] (remote-exec): test-vm
proxmox_vm_qemu.tf-vm[0] (remote-exec): is RUNNING!
proxmox_vm_qemu.tf-vm[0]: Creation complete after 1m37s [id=<PVE node name>/qemu/1001]


```

 
## Few notes:
- General consensus is to use internal NVME, SSD, HDD as the boot drive of the VM. HDD is slow but it will work but don't use external drive at all.
- Consider to split the main tf file from variables, variable declarations, credentials and providers. You can place them into separted tfvars or tf files. Terraform by default would read all files in the same directory.

variable "pm_api_url" {
  description = "The full Proxmox API URL"
  type        = string
}

variable "pm_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
}

variable "pm_api_token_id" {
  description = "Proxmox API Token ID"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to Public SSH key to inject into VM"
  type        = string
}

variable "cipassword" {
  description = "Cloud-init password for the VM"
  sensitive   = true
  type        = string
}
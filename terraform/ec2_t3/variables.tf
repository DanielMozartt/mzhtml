variable "os_type" {
  description = "Sistema operacional: linux ou windows"
  type        = string
  default     = "linux"
}

variable "public_key_path_linux" {
  description = "Caminho da chave pública no Linux"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "public_key_path_windows" {
  description = "Caminho da chave pública no Windows"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

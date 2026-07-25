variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "app_env" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
}

variable "db_name" {
  description = "Name of the application database"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "output_base_dir" {
  description = "Base directory where the generated project/ structure will be written"
  type        = string
  default     = "./project"
}

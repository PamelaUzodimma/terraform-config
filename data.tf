# Data source: pulls in content that already exists on disk BEFORE
# Terraform runs. This is different from a "resource" - Terraform
# is only reading here, never creating or destroying this file.
data "local_file" "project_seed" {
  filename = "${path.module}/seed/project_info.txt"
}

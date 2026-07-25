output "generated_files" {
  description = "All files Terraform generated for this deployment"
  value = [
    local_file.app_config.filename,
    local_file.database_config.filename,
    local_file.db_password_file.filename,
    local_file.deployment_report.filename,
  ]
}

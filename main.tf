# --- Password generation (random provider) -------------------------------

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!@#%^*-_"

  lifecycle {
    # Once a password exists, don't silently rotate it just because
    # someone tweaks length/special in future - protects a "live" db.
    ignore_changes = [length, special, override_special]
  }
}

# --- Config files (local provider) ----------------------------------------

resource "local_file" "app_config" {
  filename        = "${var.output_base_dir}/config/app.conf"
  content         = local.app_conf_content
  file_permission = "0644"
}

resource "local_file" "database_config" {
  filename = "${var.output_base_dir}/config/database.conf"

  # IMPLICIT DEPENDENCY:
  # Terraform sees random_password.db_password.result used as a
  # resource attribute right here, and automatically figures out it
  # must create random_password.db_password FIRST. No depends_on needed.
  content = <<-EOT
    ${local.database_conf_header}
    db_password = ${random_password.db_password.result}
  EOT

  file_permission = "0640"

  lifecycle {
    create_before_destroy = true
  }
}

resource "local_file" "db_password_file" {
  filename        = "${var.output_base_dir}/secrets/db_password.txt"
  content         = random_password.db_password.result
  file_permission = "0600"

  lifecycle {
    prevent_destroy = true
  }
}

resource "local_file" "deployment_report" {
  filename = "${var.output_base_dir}/reports/deployment_report.txt"

  content = <<-EOT
    Deployment Report
    ==================
    Project:      ${local.full_app_name}
    Generated at: ${local.timestamp}

    ${data.local_file.project_seed.content}
    Files created:
      - config/app.conf
      - config/database.conf
      - secrets/db_password.txt
  EOT

  # EXPLICIT DEPENDENCY:
  # Nothing in the content above forces an attribute reference to the
  # other local_file resources, so Terraform has no automatic way to
  # know this report should be written LAST. We say so ourselves.
  depends_on = [
    local_file.app_config,
    local_file.database_config,
    local_file.db_password_file,
  ]
}

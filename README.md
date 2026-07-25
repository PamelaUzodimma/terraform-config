# Terraform Local Configuration Generator

A local-only Terraform project that generates an application's config
scaffolding without touching any cloud provider.

## What gets generated

```
project/
├── config/
│   ├── app.conf
│   └── database.conf
├── secrets/
│   └── db_password.txt
└── reports/
    └── deployment_report.txt
```

## Concepts demonstrated (and where)

| Concept | File |
|---|---|
| Input variables | `variables.tf` |
| Values via `.tfvars` | `terraform.tfvars` |
| Variable referencing | `locals.tf` |
| Resource attributes | `main.tf` (`random_password.db_password.result`) |
| Implicit dependency | `main.tf` — `database_config` references the password attribute directly |
| Explicit dependency | `main.tf` — `deployment_report` uses `depends_on` |
| Multiple providers | `providers.tf` — `hashicorp/local` + `hashicorp/random` |
| Locals | `locals.tf` |
| Lifecycle rules | `main.tf` — `ignore_changes`, `create_before_destroy`, `prevent_destroy` |
| Data source | `data.tf` — reads `seed/project_info.txt` |

## How to run this yourself

```bash
terraform init
terraform plan
terraform apply
```

Type `yes` when prompted. Once it finishes, check:

```bash
find project -type f
cat project/config/app.conf
cat project/config/database.conf
cat project/secrets/db_password.txt
cat project/reports/deployment_report.txt
```

Take your screenshot right after the `terraform apply` command finishes —
you want the terminal showing the `Apply complete! Resources: 5 added, 0
changed, 0 destroyed.` line along with the file paths it printed.

## Pushing to GitHub

```bash
git init
git add .
git commit -m "Terraform local config generator - assignment submission"
git branch -M main
git remote add origin https://github.com/<your-username>/<repo-name>.git
git push -u origin main
```

Note: `terraform.tfstate` and the generated `project/` folder are excluded
via `.gitignore` — your state file can contain the plaintext DB password,
so it should never be committed.

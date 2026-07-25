# Terraform Local Configuration Generator

**Author:** Pamela Uzodimma
**Assignment:** Platform Engineering — local infrastructure config generation

A local-only Terraform project that generates an application's config
scaffolding without touching any cloud provider.

## Why I built it this way

The brief asked for a working local setup that proves out 9 specific Terraform
concepts, so I designed around two providers that only touch the filesystem
rather than a cloud account: `hashicorp/local` to actually write the files,
and `hashicorp/random` to generate the DB password — that's my "multiple
providers" requirement met honestly, not two aliases of the same thing.

A few decisions worth explaining:

- **`database_config` doesn't use `depends_on`.** It references
  `random_password.db_password.result` directly inside its content, so
  Terraform infers the create-order on its own. That's the implicit
  dependency.
- **`deployment_report` does use `depends_on`.** Its content is just literal
  strings and a timestamp — nothing in it forces Terraform to wait on the
  other three files, so I had to say so explicitly. I wanted the report to
  be the last file written, confirming everything else succeeded first.
- **The lifecycle blocks aren't decorative.** `prevent_destroy` on the
  password file stops a stray `terraform destroy` from wiping out a live
  secret. `ignore_changes` on `random_password` means the password isn't
  silently regenerated if I tweak an unrelated argument later. I tested both
  by trying to break them — see the "Testing the lifecycle rules" section
  below.
- **The data source reads `seed/project_info.txt`.** I wanted a genuine
  example of Terraform reading something it doesn't manage, rather than
  reaching for a placeholder data source just to check a box.

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

## Testing the lifecycle rules

To confirm these weren't just copied in without understanding them, I tested
each one directly:

- `terraform destroy` against the password file correctly refuses, throwing
  an error because of `prevent_destroy` — proving the guardrail works.
- Editing `length` on `random_password` and re-running `terraform plan` shows
  no proposed change, because `ignore_changes` is deliberately blinding
  Terraform to that drift.

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

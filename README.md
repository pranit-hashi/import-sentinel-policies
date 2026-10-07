# import-sentinel-policies

Sentinel policies that help ensure existing infrastructure is imported into Terraform **without downtime**, i.e. without resources being destroyed, replaced or unexpectedly modified.

These policies accompany the blog post:
[How to import existing AWS infrastructure into Terraform without downtime](https://dev.to/pranitraje/how-to-import-existing-aws-infrastructure-into-terraform-without-downtime-1h17)

> **Note: Terraform Policy (`tfpolicy`) is the newer option.**
> HashiCorp has recently introduced **Terraform Policy (tfpolicy)**, a declarative policy workflow built for Terraform and a better evolution of Sentinel for Terraform use cases. You may use tfpolicy instead of Sentinel. Read more: [Introducing tfpolicy](https://www.hashicorp.com/en/blog/introducing-tfpolicy-a-declarative-policy-workflow-built-for-terraform).
>
> This repo currently contains **only the Sentinel versions** of the policies. If you want to use tfpolicy, you will need to generate the equivalent tfpolicy files for the policies below. The [HashiCorp Agent Skill for Terraform Policy](https://github.com/hashicorp/agent-skills/tree/main/plugins/terraform/skills/terraform-policy) can help convert Sentinel policies to tfpolicy.

## Why these policies?

When you import existing resources (via `import` blocks or `terraform import`), the plan should only bring resources into state. If the plan shows deletes, replacements or updates, the generated configuration probably differs from the real infrastructure, and applying it could cause downtime. These policies catch that before apply.

## Repository layout

```
.
├── sentinel.hcl                          # Policy set configuration
└── policies/
    ├── no-destructive-changes.sentinel   # Blocks deletes and replacements
    └── flag-resource-updates.sentinel    # Flags in-place updates
```

## Policies

| Policy | Enforcement level | What it does |
| --- | --- | --- |
| `no-destructive-changes` | `hard-mandatory` | Fails if any resource would be destroyed (`delete`) or replaced (`delete,create` / `create,delete`). Skipped for explicit destroy runs (`tfrun.is_destroy`). Prints the address, type and actions of each offending resource. |
| `flag-resource-updates` | `soft-mandatory` | Fails if any resource has an in-place `update`, which may indicate drift between the imported resource and the generated code. Can be overridden by authorized users after review. |

Both policies use the `tfplan/v2` import; `no-destructive-changes` also uses `tfrun`.

### Enforcement levels

- **hard-mandatory**: must pass; cannot be overridden.
- **soft-mandatory**: must pass unless an authorized user overrides it.

## Usage

1. Add this repository as a policy set in HCP Terraform / Terraform Enterprise (VCS-backed policy set), pointing at the repo root so `sentinel.hcl` is picked up.
2. Attach the policy set to the workspaces or projects where you run imports.
3. Run a plan. Policies are evaluated after the plan and before apply.

`sentinel.hcl`:

```hcl
policy "no-destructive-changes" {
  source            = "./policies/no-destructive-changes.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "flag-resource-updates" {
  source            = "./policies/flag-resource-updates.sentinel"
  enforcement_level = "soft-mandatory"
}
```

## Migrating to tfpolicy (optional)

1. Read the [tfpolicy announcement](https://www.hashicorp.com/en/blog/introducing-tfpolicy-a-declarative-policy-workflow-built-for-terraform).
2. Use the [terraform-policy agent skill](https://github.com/hashicorp/agent-skills/tree/main/plugins/terraform/skills/terraform-policy) to convert the `.sentinel` files in `policies/`.
3. Keep the same intent: block deletes/replacements (hard enforcement) and flag in-place updates (soft enforcement).
4. Review and test the generated files before enabling them.

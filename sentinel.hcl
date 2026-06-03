policy "no-destructive-changes" {
  source            = "./policies/no-destructive-changes.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "flag-resource-updates" {
  source            = "./policies/flag-resource-updates.sentinel"
  enforcement_level = "soft-mandatory"
}

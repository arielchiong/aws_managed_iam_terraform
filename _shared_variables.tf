locals {
# YAML Files
  users  = yamldecode(file("${path.module}/users/users.yaml"))["users"]

# Policy File
  admin_policy_names = [
    for name in split("\n", file("${path.module}/policies/admin_policy.txt")) : replace(name, "\r", "")
  ]  

  dev_policy_names = [
    for name in split("\n", file("${path.module}/policies/dev_policy.txt")) : replace(name, "\r", "")
  ]  

  billing_policy_names = [
    for name in split("\n", file("${path.module}/policies/billing_policy.txt")) : replace(name, "\r", "")
  ]      

  # database_policy_names = [
  #   for name in split("\n", file("${path.module}/policies/database_policy.txt")) : replace(name, "\r", "")
  # ]     
}

# Get Policy
# Admin
data "aws_iam_policy" "admin_policy" {
  for_each = toset(local.admin_policy_names)
  
  name = each.key
}

# Dev
data "aws_iam_policy" "dev_policy" {
  for_each = toset(local.dev_policy_names)
  
  name = each.key
}

# Billing
data "aws_iam_policy" "billing_policy" {
  for_each = toset(local.billing_policy_names)
  
  name = each.key
}

# Groups
# Admin
resource "aws_iam_group" "admin_group" {
  name = var.group-admin
  path = "/"
}

# Dev
resource "aws_iam_group" "dev_group" {
  name = var.group-dev
  path = "/"
}

# Billing
resource "aws_iam_group" "billing_group" {
  name = var.group-billing
  path = "/"
}

# Database
# resource "aws_iam_group" "db_group" {
#   name = var.group-database
#   path = "/"
# }

# Policy Attachment
# Admin
resource "aws_iam_group_policy_attachment" "admin_attachment" {
  for_each = toset(local.admin_policy_names)

  group      = aws_iam_group.admin_group.name
  policy_arn = data.aws_iam_policy.admin_policy[each.key].arn
}

# Dev
resource "aws_iam_group_policy_attachment" "dev_attachment" {
  for_each = toset(local.dev_policy_names)
  
  group      = aws_iam_group.dev_group.name
  policy_arn = data.aws_iam_policy.dev_policy[each.key].arn
}
# Billing
resource "aws_iam_group_policy_attachment" "billing_attachment" {
  for_each = toset(local.billing_policy_names)

  group      = aws_iam_group.billing_group.name
  policy_arn = data.aws_iam_policy.billing_policy[each.key].arn
}

# Uncomment to use
# Attach custom IAM policy check iam-policy.tf
# resource "aws_iam_group_policy_attachment" "custom_attachment" {
#   group      = aws_iam_group.dev_group.name
#   policy_arn = aws_iam_policy.support-policy.arn
# }

# Loop in email in users.yaml file
resource "aws_iam_user" "iam_users" {
  for_each = { 
      for users in local.users : users.name => users 
  }
  name = each.value.email
  tags = {
    Name = each.value.name
    ManagedBy = "Terraform"
    Group = each.value.tags
  }  
}

# Loop in array of groups in users.yaml file
resource "aws_iam_user_group_membership" "users_group_attachment" {
  for_each = { for user in local.users : user.name => user }

  user   = aws_iam_user.iam_users[each.key].name
  groups = each.value.groups != null ? [
    for group in each.value.groups :
    group == "Admin" ? aws_iam_group.admin_group.name : 
    group == "Dev" ? aws_iam_group.dev_group.name : 
    # group == "Database" ? aws_iam_group.db_group.name :
    aws_iam_group.billing_group.name
  ] : []
}

resource "aws_iam_access_key" "iam_user_key" {
  for_each = { for user in local.users : user.name => user if user.access_keys }
  user  = aws_iam_user.iam_users[each.key].name  
}

resource "aws_iam_user_login_profile" "iam_users_login" {
  for_each = { for user in local.users : user.name => user if user.console_login }
  user     = aws_iam_user.iam_users[each.key].name  
  password_reset_required = true
  lifecycle {
    ignore_changes = [password_length, password_reset_required] #Ignore user change password
  }
}

output "access_keys" {
  sensitive = true
  value = [ 
    for access_key in aws_iam_access_key.iam_user_key : 
      "User: ${access_key.user} AccessKeyId: ${access_key.id} SecretKey: ${access_key.secret}" 
      if access_key.id != null && access_key.secret != null
    ]
}

output "user_password" {
  sensitive = true
  value = [
    for secrets in aws_iam_user_login_profile.iam_users_login :
    secrets.password != null ? "User: ${secrets.user} password: ${secrets.password}" : null
  ]  
}

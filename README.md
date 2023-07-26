### Terraform for AWS IAM USERS (Keys, Console Login)
This Terraform scripts creates and manages AWS IAM User with or without AWS login or AWS Access keys and add users to groups `Admin` `Dev` `Billing` or can add more.

Best to use for Organizations without SSO integrations in AWS and only managed users in AWS. This also supports importing existing IAM users for easy management moving forward.

> make sure your AWS account has the right access to create the resources.

## AWS Provider
provider and backend configuration `_provider.tf`
Enable and create the following if need to store terraform state in AWS S3

```
  backend "s3"{
    bucket = "your-terraform-state-bucket"
    key = "folder/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "your-terraform-terraform-statefile-locks"
    encrypt = true
  }
```
## Add IAM User

Below are the details needed to create IAM user

| Name | Value | Description |
| ------ | ------ | ------ |
| Name | John Smith | Name of user
| Email | john.smith@example.com | to be use to login in AWS console
| Groups | Admin, Dev, Billing | one or more groups can be added
| Access Keys | true or false | if user need some access keys for cli
| Console Login | true or false | if user need console login
| Tags | "DevOps" "Dev" "QA" "Data" or any | Team Tags only one is allowed

> Append the following in file `users/users.yaml`
```
- name: John Smith
  email: john.smith@example.com
  groups:
    - Admin
  access_keys: false
  console_login: true
  tags: "DevOps"  
```
## Importing Existing IAM User to Terraform
> Note: Make sure user is added in `users/users.yaml`.
```
- name: John Smith
  email: john.smith@example.com
  groups:
    - Admin
  access_keys: false
  console_login: true
  tags: "DevOps"  
```

### Terraform Import IAM USER
```
terraform import 'aws_iam_user.iam_users["name in yaml file"]' name_in_yaml_file
e.g.
terraform import 'aws_iam_user.iam_users["John Smith"]' john.smith@laconicglobal.com
```

### Terraform Import IAM USER KEY
> if user has existing access key and make sure to set the value to true in `users/users.yaml` `access_keys: true`
```
terraform import 'aws_iam_access_key.iam_user_key["name in yaml file"]' ACCESS_KEY_NAME
e.g.
terraform import 'aws_iam_access_key.iam_user_key["John Smith"]' AKIA5EIAMX7KUQILMZJX
```

## Login profile
```
terraform import 'aws_iam_user_login_profile.iam_users_login["name in yaml file"]' login_name
e.g.
terraform import 'aws_iam_user_login_profile.iam_users_login["Kianhow Tan"]' john.smith@example.com
```
## Groups
```
terraform import 'aws_iam_user_group_membership.users_group_attachment["name in yaml file"]' login-name/group-name
e.g.
terraform import 'aws_iam_user_group_membership.users_group_attachment["John Smith"]' john.smith@laconicglobal.com/singapore-team
```

## Output
#### To show users access keys
```
terraform output access_keys
```
#### To show users password
```
terraform output user_password
```

## Policies
Add existing AWS policies 
> `policies/admin_policy.txt`
```
AdministratorAccess    
```
> `policies/dev_policy.txt` 
```
ReadOnlyAccess
IAMUserChangePassword
AmazonRDSPerformanceInsightsReadOnly
```
> `policies/billing_policy.txt` 
```
Billing
```

### Custom policies
update `iam-policy.tf` and `users.tf`

## Variable file
```
variable "group-admin" {
  type = string
  default = "Admin"
}

variable "group-dev" {
  type = string
  default = "Dev"
}

variable "group-billing" {
  type = string
  default = "Billing"
}

# Can add more groups
# variable "group-database" {
#   type = string
#   default = "Database"
# }
```
## Local shared variable configuration file `_shared_variables.tf` 
```
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
```

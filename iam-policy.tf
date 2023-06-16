# # Custom Policies
# resource "aws_iam_policy" "support-policy" {
#   name = "cloudwatch-read-only-policy"
#   policy = jsonencode({
#   Version = "2012-10-17"
#   Statement = [
#         {
#           Action   = [
#             "cloudwatch:DescribeInsightRules",
#             "cloudwatch:DescribeAlarmHistory",
#             "cloudwatch:GetDashboard",
#             "cloudwatch:GetInsightRuleReport",
#             "cloudwatch:GetMetricData",
#             "cloudwatch:DescribeAlarmsForMetric",
#             "cloudwatch:DescribeAlarms",
#             "cloudwatch:GetMetricStream",
#             "cloudwatch:GetMetricStatistics",
#             "cloudwatch:GetMetricWidgetImage",
#             "cloudwatch:ListManagedInsightRules",
#             "cloudwatch:DescribeAnomalyDetectors"            
#           ]
#           Effect   = "Allow"
#           Resource = ["*"]
#         }
#     ]
#   })

#   tags = {
#     Name = "cloudwatch-read-only-policy"
#     ManagedBy = "Terraform"
#   }  
# }

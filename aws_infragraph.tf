data "tls_certificate" "provider" {
  url = "https://idp.hcp.to"
}

resource "aws_iam_openid_connect_provider" "hcp_resource_graph" {
  url = "https://idp.hcp.to/oidc/organization/3118f9c6-3ad5-496c-9e99-44cfca94942e"

  client_id_list = [
    "aws.workload.identity", # Default audience in HCP resource graph for AWS.
  ]

  thumbprint_list = [
    data.tls_certificate.provider.certificates[0].sha1_fingerprint,
  ]
}

data "aws_iam_policy_document" "hcp_resource_graph_oidc_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.hcp_resource_graph.arn]
    }
  }
}

resource "aws_iam_role" "hcp_resource_graph_role" {
  name               = "hcp_resource_graph-role"
  assume_role_policy = data.aws_iam_policy_document.hcp_resource_graph_oidc_assume_role_policy.json
}

data "aws_iam_policy_document" "hcp_resource_graph_resource_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      // Account
      "account:GetAccountInformation",

      // CloudFormation
      "cloudformation:GetResource",
      "cloudformation:ListResources",


      // CloudWatch
      "logs:DescribeLogGroups",
      "logs:ListTagsForResource",
      "cloudwatch:DescribeAlarms",
      "events:ListRules",
      "events:DescribeRule",
      "events:ListTagsForResource",
      "events:ListTargetsByRule",


      // EC2
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeRegions",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
      "ec2:DescribeVpcs",

      // ECS
      "ecs:DescribeClusters",
      "ecs:DescribeServices",
      "ecs:ListClusters",
      "ecs:ListServices",

      // IAM
      "iam:ListAttachedRolePolicies",
      "iam:ListPolicies",
      "iam:ListRoles",
      "iam:ListUsers",

      // Lambda
      "lambda:ListFunctions",
      "lambda:GetPolicy",

      // RDS
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",

      // S3
      "s3:ListAllMyBuckets",
      "s3:GetBucketPublicAccessBlock",

      // sqs
      "sqs:ListQueues",
      "sqs:GetQueueAttributes",

      // EKS
      "eks:ListClusters",
      "eks:DescribeCluster",

      // SNS
      "sns:ListTopics",
      "sns:GetTopicAttributes",
      "sns:ListSubscriptions",
      "sns:GetSubscriptionAttributes",

      // Route53
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource",
      "route53:ListQueryLoggingConfigs",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "hcp_resource_graph_resource_access_policy" {
  name        = "hcp_resource_graph-resource-policy"
  description = "A policy that allows the resource graph to access resources"
  policy      = data.aws_iam_policy_document.hcp_resource_graph_resource_access_policy.json
}

resource "aws_iam_role_policy_attachment" "hcp_resource_graph_access_resources_policy_attachment" {
  role       = aws_iam_role.hcp_resource_graph_role.name
  policy_arn = aws_iam_policy.hcp_resource_graph_resource_access_policy.arn
}

data "aws_iam_policy_document" "hcp_resource_graph_assumerole_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRoleWithWebIdentity"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "hcp_resource_graph_assumerole_policy" {
  name        = "hcp_resource_graph-assume-role-policy"
  description = "A policy that allows the resource graph to call sts:AssumeRoleWithWebIdentity"
  policy      = data.aws_iam_policy_document.hcp_resource_graph_assumerole_policy.json
}

resource "aws_iam_role_policy_attachment" "hcp_resource_graph_assume_policy_attachment" {
  role       = aws_iam_role.hcp_resource_graph_role.name
  policy_arn = aws_iam_policy.hcp_resource_graph_assumerole_policy.arn
}

output "role_arn" {
  value = aws_iam_role.hcp_resource_graph_role.arn
}

output "role_name" {
  value = aws_iam_role.hcp_resource_graph_role.name
}
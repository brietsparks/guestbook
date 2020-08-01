resource "aws_iam_role" "guestbook_ci_codepipeline" {
  name = "GuestbookCiCodePipelineS3AccessRoleAssumption"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "guestbook_ci_codepipeline" {
  name = "guestbook_ci_s3_access"
  role = aws_iam_role.guestbook_ci_codepipeline.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.guestbook_ci.arn}",
        "${aws_s3_bucket.guestbook_ci.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "guestbook_ci_codebuild" {
  name = "guestbook_ci_codebuild"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-codebuild-project.html#aws-resource-codebuild-project--examples
resource "aws_iam_role_policy" "guestbook_ci_codebuild" {
  role = aws_iam_role.guestbook_ci_codebuild.name
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.guestbook_ci.arn}",
        "${aws_s3_bucket.guestbook_ci.arn}/*"
      ]
    }
  ]
}
POLICY
}

//resource "aws_iam_role_policy" "guestbook_ci_codebuild" {
//  role = aws_iam_role.guestbook_ci_codebuild.name
//  policy = <<POLICY
//{
//  "Version": "2012-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow",
//      "Resource": [
//        "*"
//      ],
//      "Action": [
//        "logs:CreateLogGroup",
//        "logs:CreateLogStream",
//        "logs:PutLogEvents"
//      ]
//    },
//    {
//      "Effect": "Allow",
//      "Action": [
//        "ec2:CreateNetworkInterface",
//        "ec2:DescribeDhcpOptions",
//        "ec2:DescribeNetworkInterfaces",
//        "ec2:DeleteNetworkInterface",
//        "ec2:DescribeSubnets",
//        "ec2:DescribeSecurityGroups",
//        "ec2:DescribeVpcs"
//      ],
//      "Resource": "*"
//    },
//    {
//      "Effect": "Allow",
//      "Action": [
//        "ec2:CreateNetworkInterfacePermission"
//      ],
//      "Resource": [
//        "arn:aws:ec2:us-east-1:123456789012:network-interface/*"
//      ],
//      "Condition": {
//        "StringEquals": {
//          "ec2:Subnet": ${module.vpc.private_subnets},
//          "ec2:AuthorizedService": "codebuild.amazonaws.com"
//        }
//      }
//    },
//    {
//      "Effect": "Allow",
//      "Action": [
//        "s3:*"
//      ],
//      "Resource": [
//        "${aws_s3_bucket.guestbook_ci.arn}",
//        "${aws_s3_bucket.guestbook_ci.arn}/*"
//      ]
//    }
//  ]
//}
//POLICY
//}

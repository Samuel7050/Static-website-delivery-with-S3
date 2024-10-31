
data "aws_caller_identity" "current" {}

data "archive_file" "website_zip" {
  type        = "zip"
  source_dir = "function"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda_function"  {
  filename      = data.archive_file.website_zip.output_path
  function_name = var.function_name
  role          =aws_iam_role.lambda_exec_role.arn
  handler       = "lambda.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.website_zip.output_path)
  runtime = "python3.8"
   vpc_config {
    subnet_ids         = [var.private_subnet_az1_id, var.private_subnet_az2_id]
    security_group_ids = [var.lambda_sg_id, var.alb_sg_id]
  }
 
 
  depends_on = [aws_iam_role_policy_attachment.lambda_combined_policy ]
  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
      BUCKET_KEY  = var.bucket_key 
    }
  } 
}
  
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_s3_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_combined_policy" {
  name = "LambdaCombinedPolicy"
  description = "lambda policy document for s3,vpc,cloudwatch"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",         # Bucket ARN
          "arn:aws:s3:::${var.bucket_name}/*"        # Object ARN
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "lambda_combined_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_combined_policy.arn
}

resource "aws_lambda_permission" "allow_alb_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromALB"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.function_name}"
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = var.alb_tg_arn
}
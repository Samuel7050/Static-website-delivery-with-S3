output "lambda_invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}

output "lambda_fubction_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "lambda_url" {
 value= aws_lambda_function.lambda_function.image_uri
}

output "lambda_function_name" {
  value = aws_lambda_function.lambda_function.function_name
}

output "allow_alb_to_invoke_lambda"{
  value = aws_lambda_permission.allow_alb_to_invoke_lambda.function_name
  
}

output "lambda_exec_role" {
  value= aws_iam_role.lambda_exec_role.arn
  }
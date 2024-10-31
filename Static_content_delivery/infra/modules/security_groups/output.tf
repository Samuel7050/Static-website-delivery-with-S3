output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "alb_sg_arn" {
  value = aws_security_group.alb_sg.arn
}

output "lambda_sg_arn" {
  value = aws_security_group.lambda_sg.arn
}
# Apllication Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "enable http access on port 80"
  vpc_id      = var.vpc_id

ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

   egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

tags   = {
    Name = "alb_sg"
  }

 }
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "lambda_sg"
  vpc_id      = var.vpc_id


ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

   egress {
    from_port        = 0
    to_port          = 0    
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }
tags   = {
    Name = "lambda_sg"
  }
}
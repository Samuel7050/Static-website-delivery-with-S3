
module "vpc" {
  source                  = "./infra/modules/vpc"
  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  public_subnet_az1_cidr  = var.public_subnet_az1_cidr
  public_subnet_az2_cidr  = var.public_subnet_az2_cidr
  private_subnet_az1_cidr = var.private_subnet_az1_cidr
  private_subnet_az2_cidr = var.private_subnet_az2_cidr

}

module "security_groups" {
  source = "./infra/modules/security_groups"
  vpc_id = module.vpc.vpc_id
}


module "nat_gateway" {
  source                = "./infra/modules/nat_gateway"
  vpc_id                = module.vpc.vpc_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  private_subnet_az1_id = module.vpc.private_subnet_az1_id
  private_subnet_az2_id = module.vpc.private_subnet_az2_id
}

module "lambda" {
  source                = "./infra/modules/lambda"
  function_name         = var.function_name
  bucket_name           = module.s3.bucket_name
  region                = var.region
  private_subnet_az1_id = module.vpc.private_subnet_az1_id
  private_subnet_az2_id = module.vpc.private_subnet_az2_id
  lambda_sg_id          = module.security_groups.lambda_sg_id
  alb_tg_arn            = module.alb.alb_tg_arn
  bucket_key            = var.bucket_key
  alb_sg_id             = module.security_groups.alb_sg_id
}


module "alb" {
  source                     = "./infra/modules/alb"
  project_name               = var.project_name
  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  alb_sg_id                  = module.security_groups.alb_sg_id
  vpc_id                     = module.vpc.vpc_id
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  lambda_fubction_arn        = module.lambda.lambda_fubction_arn
  allow_alb_to_invoke_lambda = module.lambda.allow_alb_to_invoke_lambda
}




module "s3" {
  source           = "./infra/modules/s3_bucket"
  bucket_name      = var.bucket_name
  bucket_key       = var.bucket_key
  region           = var.region
  lambda_exec_role = module.lambda.lambda_exec_role
}


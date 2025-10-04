module "vpc" {
  source          = "../modules/vpc-no-nat"
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security" {
  source       = "../modules/security"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

module "cognito" {
  count         = var.enable_cognito ? 1 : 0
  source        = "../modules/cognito"
  project_name = var.project_name
  domain_prefix = var.cognito_domain_prefix
}

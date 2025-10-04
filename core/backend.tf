terraform {
  backend "s3" {
    bucket = "tazzcn-tf-state-bucket"
    key    = "core.tfstate"
    region = "eu-west-2"
    encrypt = true
    use_lockfile = true
    dynamodb_table = "terraform-locks"
  }
}
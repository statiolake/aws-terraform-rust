provider "aws" {
  region                   = "ap-northeast-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile
  default_tags {
    tags = {
      managed_by = "terraform"
    }
  }
}

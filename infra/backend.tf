terraform {
  backend "s3" {
    bucket         = "tfstate-132410971191-craftista"
    key            = "craftista/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock-craftista"
    encrypt        = true
  }
}

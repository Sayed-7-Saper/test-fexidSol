terraform {
  backend "s3" {
    bucket         = "testfixedsol3330"
    key            = "fixedSol/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "backend"
  }

}
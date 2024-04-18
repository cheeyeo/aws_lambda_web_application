terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "github-tf-state-2024"
    key    = "aws-lambda-flask-state/terraform.tfstate"
    region = "eu-west-1"
    encrypt = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Create DynamoDB
module "dynamodb" {
  source = "./dynamodb"
  hash_key = "ID" # partition / primary key
  name = "Quotation"
  global_index_name = "QuotationIndex"
  non_key_attributes = ["Author", "Quotation"]
}

# Create Lambda
module "lambda" {
  source       = "./lambda"
  dynamodb_arn = module.dynamodb.quotation_table_arn
  dynamodb_name = module.dynamodb.quotation_table_name
  dynamodb_index_name = module.dynamodb.table_index_name
}

output "dynamodb_name" {
  value = module.dynamodb.quotation_table_name
}

output "ecr_repo_url" {
  value = module.lambda.ecr_url
}

output "function_url" {
  value = module.lambda.function_url
}
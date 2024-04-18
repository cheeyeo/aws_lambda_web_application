variable "dynamodb_arn" {
  description = "DynamoDB arn"
}

variable "dynamodb_name" {
  description = "DynamoDB name"
}

variable "dynamodb_index_name" {
  description = "DynamoDB index name"
}

variable "image_tag" {
    description = "ECR Image tag of Lambda function to deploy"
    default = "latest"
}
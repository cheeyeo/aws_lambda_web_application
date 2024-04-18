# Test dynamodb
resource "aws_dynamodb_table" "quotation" {
    name = var.name
    billing_mode = "PAY_PER_REQUEST"
    hash_key = var.hash_key

    attribute {
        name = "ID"
        type = "N"
    }

    global_secondary_index {
        name               = var.global_index_name
        hash_key           = var.hash_key
        non_key_attributes = var.non_key_attributes
        write_capacity     = 10
        read_capacity      = 10
        projection_type    = "INCLUDE"
    }
}

output "quotation_table_name" {
    description = "Name of quotation DynamoDB table"
    value = aws_dynamodb_table.quotation.name
}

output "quotation_table_arn" {
    description = "ARN of quotation DynamoDB table"
    value = aws_dynamodb_table.quotation.arn
}

output "table_index_name" {
  value = var.global_index_name
}
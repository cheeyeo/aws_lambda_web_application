data "aws_iam_policy_document" "AWSLambdaTrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flask_webapp" {
    name = "FlaskWebapp"
    assume_role_policy = data.aws_iam_policy_document.AWSLambdaTrustPolicy.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role" {
    role = aws_iam_role.flask_webapp.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "documentdb_role" {
    role = aws_iam_role.flask_webapp.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

# Allow for SCAN on table
data "aws_iam_policy_document" "dynamodb_scan_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [var.dynamodb_arn]
  }
}

resource "aws_iam_policy" "query_dynamodb" {
  name = "QueryDynamoDB"
  description = "Allow to scan and query dynamodb"
  policy = data.aws_iam_policy_document.dynamodb_scan_policy.json
}

resource "aws_iam_role_policy_attachment" "query_dynamodb" {
  role = aws_iam_role.flask_webapp.name
  policy_arn = aws_iam_policy.query_dynamodb.arn
}
resource "aws_ecr_repository" "lambda_repository" {
  name                 = "flask-lambda"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_lambda_function" "flask_webapp" {
    function_name = "FlaskWebapp"
    image_uri = "${aws_ecr_repository.lambda_repository.repository_url}:${var.image_tag}"
    package_type = "Image"
    role = aws_iam_role.flask_webapp.arn
    depends_on = [aws_iam_role.flask_webapp]
    publish = true
    timeout = 60

    environment {
      variables = {
        DYNAMODB = var.dynamodb_name
        DYNAMODB_INDEX = var.dynamodb_index_name
      }
    }
}

resource "aws_cloudwatch_log_group" "flask_webapp" {
  name = "/aws/lambda/${aws_lambda_function.flask_webapp.function_name}"

  retention_in_days = 30
}

resource "aws_lambda_function_url" "flask_webapp" {
  function_name      = aws_lambda_function.flask_webapp.function_name
  authorization_type = "NONE"
}


output "ecr_url" {
  value = aws_ecr_repository.lambda_repository.repository_url
}

output "function_url" {
  value = aws_lambda_function_url.flask_webapp.function_url
}
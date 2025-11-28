resource "aws_dynamodb_table" "php_session_handler" {
  name         = "php_session_handler"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expires"
    enabled        = true
  }

  tags = local.tags
}

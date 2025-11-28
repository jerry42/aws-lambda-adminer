resource "aws_api_gateway_rest_api" "adminer" {
  name               = "adminer"
  tags               = local.tags
  binary_media_types = ["*/*"]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = var.allowed_ip_addresses
          }
        }
      }
    ]
  })
}

resource "aws_api_gateway_resource" "adminer_php" {
  rest_api_id = aws_api_gateway_rest_api.adminer.id
  parent_id   = aws_api_gateway_rest_api.adminer.root_resource_id
  path_part   = "adminer.php"
}

resource "aws_api_gateway_method" "adminer_any" {
  rest_api_id   = aws_api_gateway_rest_api.adminer.id
  resource_id   = aws_api_gateway_resource.adminer_php.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "adminer_any" {
  rest_api_id             = aws_api_gateway_rest_api.adminer.id
  resource_id             = aws_api_gateway_resource.adminer_php.id
  http_method             = aws_api_gateway_method.adminer_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.adminer.invoke_arn
}

resource "aws_api_gateway_deployment" "adminer" {
  rest_api_id = aws_api_gateway_rest_api.adminer.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.adminer_php.id,
      aws_api_gateway_method.adminer_any.id,
      aws_api_gateway_integration.adminer_any.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.adminer.id
  deployment_id = aws_api_gateway_deployment.adminer.id
  stage_name    = "prod"
  tags          = local.tags
}

resource "aws_api_gateway_domain_name" "adminer" {
  domain_name              = var.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.adminer.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = local.tags
}

resource "aws_api_gateway_base_path_mapping" "adminer" {
  api_id      = aws_api_gateway_rest_api.adminer.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  domain_name = aws_api_gateway_domain_name.adminer.domain_name
}

resource "aws_acm_certificate" "adminer" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_acm_certificate_validation" "adminer" {
  certificate_arn         = aws_acm_certificate.adminer.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.adminer.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.ugtab.zone_id
}

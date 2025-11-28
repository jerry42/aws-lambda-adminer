resource "aws_ecr_repository" "adminer" {
  name                 = "adminer"
  image_tag_mutability = "MUTABLE"

  tags = local.tags
}

resource "aws_ecr_lifecycle_policy" "adminer" {
  repository = aws_ecr_repository.adminer.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep only the five most recent images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

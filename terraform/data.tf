data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*${var.subnet_filter_name}*"]
  }
}
data "aws_ecr_image" "repo_image" {
  repository_name = aws_ecr_repository.adminer.name
  image_tag       = "latest"
}
data "aws_route53_zone" "ugtab" {
  name         = var.dns_zone
  private_zone = false
}
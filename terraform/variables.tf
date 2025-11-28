variable "vpc_name" {
  type = string
}

variable "subnet_filter_name" {
  type = string
}

variable "allowed_ip_addresses" {
  type        = list(string)
  description = "List of IP addresses allowed to access the API Gateway"
}
variable "domain_name" {
  type = string
}
variable "dns_zone" {
  type = string
}
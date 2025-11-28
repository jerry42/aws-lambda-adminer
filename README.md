# Adminer Terraform Infrastructure

This directory contains the Terraform configuration for deploying Adminer as a serverless application on AWS.

## Overview

The infrastructure deploys Adminer using AWS Lambda and API Gateway, providing a cost-effective and scalable solution for database management.

### Key Components

*   **AWS Lambda**: Runs the Adminer PHP application using a Docker container image.
*   **Amazon API Gateway**: Exposes the Adminer application via a REST API. Access is restricted to specific IP addresses for security.
*   **Amazon DynamoDB**: Stores PHP sessions, allowing for stateless Lambda execution.
*   **Amazon ECR**: Hosts the Docker image used by the Lambda function.
*   **Amazon Route 53 & ACM**: Manages the custom domain name and SSL/TLS certificate.

## Prerequisites

*   Terraform >= 1.5.0
*   AWS Credentials configured
*   An existing VPC and Subnets
*   A Route 53 Hosted Zone

## Configuration

The deployment is configured using the following variables:

| Variable | Description | Type |
|---|---|---|
| `vpc_name` | The name of the VPC where the Lambda function will be deployed. | `string` |
| `subnet_filter_name` | A string to filter the subnets within the VPC (e.g., "private"). | `string` |
| `allowed_ip_addresses` | A list of IP addresses (CIDR notation) allowed to access the Adminer interface. | `list(string)` |
| `domain_name` | The custom domain name for the Adminer application (e.g., "db.example.com"). | `string` |
| `dns_zone` | The name of the Route 53 hosted zone for the domain. | `string` |

## Deployment

1.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

2.  **Plan the deployment:**
    ```bash
    terraform plan -var-file="config.tfvars"
    ```

3.  **Apply the configuration:**
    ```bash
    terraform apply -var-file="config.tfvars"
    ```

## Outputs

After a successful application, Terraform will output the following information:

*   `lambda_function_name`: The name of the created Lambda function.
*   `api_gateway_invoke_url`: The default invoke URL for the API Gateway.
*   `custom_domain_url`: The custom domain URL for accessing Adminer.
*   `dynamodb_table_name`: The name of the DynamoDB table used for sessions.
*   `ecr_repository_url`: The URL of the ECR repository.

## Security

*   **Network Access**: The API Gateway is configured with a Resource Policy that only allows traffic from the IPs specified in `allowed_ip_addresses`.
*   **VPC**: The Lambda function is deployed within your VPC, ensuring secure access to your internal databases.
*   **Encryption**: HTTPS is enforced via API Gateway and ACM certificates.

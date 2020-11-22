# aws-static-site template

Boilerplate for Terraform to hosting a static site on AWS S3 served via CloudFront.

## Setup

1. Install [AWS CLI](https://docs.aws.amazon.com/cli/index.html)
2. Authenticate the AWS CLI
3. Install [Terraform](https://www.terraform.io/downloads.html)
4. `cd terraform && terraform init -backend-config=prod.hcl`

## Usage

```sh
cd terraform
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

## TODO

* Logging
  * Lambda function for cache invalidation
  * (Access logs)
* Headers
  * CORS
  * CSP
  * Endless cache (min, default, max ttl)

# Static site hosted on AWS

## Setup

1. Install [AWS CLI](https://docs.aws.amazon.com/cli/index.html)
2. Authenticate the AWS CLI
3. Install [Terraform](https://www.terraform.io/downloads.html)

## Usage

```sh
terraform init -backend-config=prod.hcl
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

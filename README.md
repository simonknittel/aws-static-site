# aws-static-site

Boilerplate for Terraform to host a static site on Amazon S3 served via CloudFront.

## Setup

1. Install and authenticate the [AWS CLI](https://docs.aws.amazon.com/cli/index.html)
2. Install [Terraform](https://www.terraform.io/downloads.html)
3. Initialize Terraform: `cd terraform && terraform init -backend-config=prod.hcl`

## Usage

```sh
cd terraform
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

## Overview

<div align="center">
  <img src="https://raw.githubusercontent.com/simonknittel/aws-static-site/master/docs/architecture.png">
</div>

* cache_invalidation/
  * Contains the (Lambda) code to execute cache invalidation on our CDN (CloudFront) when files on our origin (S3 bucket) change
* site/
  * Contains the site
* terraform/
  * Contains all Terraform related things
* terraform/origin.tf
  * Handles setting up the origin (S3 bucket) and upload of the site
* terraform/cdn.tf
  * Handles serving the origins' content via our CDN (CloudFront)
* terraform/dns.tf
  * Handles pointing the DNS to the CDN (in this case, the DNS provider is Cloudflare)
* terraform/cache_invalidation.tf
  * Sets up the cache invalidation via Lambda

## TODO

* Logging
  * Execution of the cache invalidation Lambda function
  * Maybe access logs
* Headers
  * CSP
  * CORS
  * Endless cache (min, default, max ttl)
* Redirect for www.

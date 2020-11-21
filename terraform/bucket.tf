resource "aws_s3_bucket" "bucket" {
  bucket = local.full_domain
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "5xx.html"
  }
}

resource "aws_s3_bucket" "redirect_bucket" {
  bucket = "www.${local.full_domain}"
  force_destroy = true

  website {
    redirect_all_requests_to = local.full_domain
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "null_resource" "upload" {
  triggers = {
    always = timestamp()
  }

  provisioner "local-exec" {
    command = "aws s3 sync --delete ../site s3://${aws_s3_bucket.bucket.id}"
  }
}

# BUG: The following would be the more Terraform way of uploading multiple files
# but on upload the correct content types are missing
# resource "aws_s3_bucket_object" "files" {
#   for_each = fileset("../site", "**")

#   bucket = aws_s3_bucket.bucket.bucket
#   key = each.value
#   source = "../site/${each.value}"
# }

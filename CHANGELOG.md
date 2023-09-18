## Changelog

### `1.2.5`

- Move s3 website configuration to it's own resource `aws_s3_bucket_website_configuration`.
- Block S3 public access and set bucket ACL to `private`.
- Add tags to `aws_cloudfront_distribution`.

### `1.2.4`

- Add `aws_s3_bucket_versioning`, and tag s3 buckets per org guidelines.
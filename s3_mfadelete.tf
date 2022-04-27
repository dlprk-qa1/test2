resource "aws_s3_bucket" "mfadelete1" {
  bucket = "examplebuckettftest"
  acl    = "private"
  versioning {
    enabled    = true
    mfa_delete = "false"
  }
}

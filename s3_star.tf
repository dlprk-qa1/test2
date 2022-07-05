
resource "aws_s3_bucket" "S3_Compliant_Bucket" {
 count      = 1
 bucket     = var.test_variable[*].name
 force_destroy  = true
}

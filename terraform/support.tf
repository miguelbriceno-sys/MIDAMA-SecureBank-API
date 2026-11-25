resource "aws_subnet" "secondary" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.42.12.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
}
resource "aws_db_subnet_group" "bank" {
  name       = "${var.prefix}-private"
  subnet_ids = [aws_subnet.private.id, aws_subnet.secondary.id]
}
locals {
  buckets = { backups = aws_s3_bucket.backups.id, logs = aws_s3_bucket.logs.id }
}
resource "aws_s3_bucket_public_access_block" "bank" {
  for_each                = local.buckets
  bucket                  = each.value
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_versioning" "bank" {
  for_each = local.buckets
  bucket   = each.value
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "bank" {
  for_each = local.buckets
  bucket   = each.value
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Sid = "AclForServices", Effect = "Allow", Principal = { Service = ["cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com"] }, Action = "s3:GetBucketAcl", Resource = aws_s3_bucket.logs.arn, Condition = { StringEquals = { "aws:SourceAccount" = local.account } } },
      { Sid = "Delivery", Effect = "Allow", Principal = { Service = ["cloudtrail.amazonaws.com", "delivery.logs.amazonaws.com"] }, Action = "s3:PutObject", Resource = "${aws_s3_bucket.logs.arn}/AWSLogs/${local.account}/*", Condition = { StringEquals = { "aws:SourceAccount" = local.account, "s3:x-amz-acl" = "bucket-owner-full-control" } } },
      { Sid = "Transport", Effect = "Deny", Principal = "*", Action = "s3:*", Resource = [aws_s3_bucket.logs.arn, "${aws_s3_bucket.logs.arn}/*"], Condition = { Bool = { "aws:SecureTransport" = "false" } } }
    ]
  })
}
resource "aws_iam_role_policy" "app" {
  name = "registrar-eventos"
  role = aws_iam_role.app.id
  policy = jsonencode({ Version = "2012-10-17", Statement = [
    { Effect = "Allow", Action = ["dynamodb:PutItem"], Resource = aws_dynamodb_table.txn.arn },
    { Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents"], Resource = "${aws_cloudwatch_log_group.lambda.arn}:*" }
  ] })
}
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.prefix}-events"
  retention_in_days = 30
}

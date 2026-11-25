resource "aws_vpc" "main" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_hostnames = true
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.42.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
}
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.42.11.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
}
resource "aws_security_group" "web" {
  name_prefix = "bank-web-"
  description = "Trafico HTTPS del laboratorio"
  vpc_id      = aws_vpc.main.id
  ingress {
    description = "HTTPS de la red de laboratorio"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.42.0.0/16"]
  }
}
resource "aws_security_group" "db" {
  name_prefix = "bank-db-"
  description = "PostgreSQL desde el servicio"
  vpc_id      = aws_vpc.main.id
  ingress {
    description     = "PostgreSQL desde los nodos autorizados"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
}
resource "aws_instance" "web" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = false
  monitoring                  = true
  metadata_options { http_tokens = "required" }
  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.bank.arn
    volume_type = "gp3"
  }
}
resource "aws_instance" "worker" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = false
  monitoring                  = true
  metadata_options { http_tokens = "required" }
  root_block_device {
    encrypted   = true
    kms_key_id  = aws_kms_key.bank.arn
    volume_type = "gp3"
  }
}
resource "aws_s3_bucket" "backups" {
  bucket        = "${var.prefix}-backups-${local.account}"
  force_destroy = false
}
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.prefix}-logs-${local.account}"
  force_destroy = false
}
resource "aws_db_instance" "postgres" {
  identifier                      = "${var.prefix}-db"
  engine                          = "postgres"
  instance_class                  = "db.t4g.micro"
  allocated_storage               = 20
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.bank.arn
  username                        = "bankadmin"
  manage_master_user_password     = true
  publicly_accessible             = false
  multi_az                        = true
  backup_retention_period         = 7
  deletion_protection             = true
  skip_final_snapshot             = false
  final_snapshot_identifier       = "${var.prefix}-final"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  db_subnet_group_name            = aws_db_subnet_group.bank.name
  vpc_security_group_ids          = [aws_security_group.db.id]
  auto_minor_version_upgrade      = true
}
resource "aws_dynamodb_table" "txn" {
  name         = "${var.prefix}-txn"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  point_in_time_recovery { enabled = true }
  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.bank.arn
  }
}
resource "aws_iam_role" "app" {
  name_prefix        = "bank-app-"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_user" "ci" {
  name = "${var.prefix}-auditoria"
  path = "/laboratorio/"
  # Identidad de inventario. CI usa OIDC. No se emiten claves para este usuario.
}
resource "aws_kms_key" "bank" {
  description             = "Cifrado de los recursos del laboratorio bancario"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}
resource "aws_lb" "front" {
  name                       = "${var.prefix}-alb"
  load_balancer_type         = "application"
  internal                   = true
  security_groups            = [aws_security_group.web.id]
  subnets                    = [aws_subnet.public.id, aws_subnet.secondary.id]
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  desync_mitigation_mode     = "strictest"
}
resource "aws_cloudtrail" "audit" {
  name                          = "${var.prefix}-trail"
  s3_bucket_name                = aws_s3_bucket.logs.id
  enable_logging                = true
  enable_log_file_validation    = true
  is_multi_region_trail         = true
  include_global_service_events = true
  depends_on                    = [aws_s3_bucket_policy.logs]
}
resource "aws_flow_log" "network" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.logs.arn
  depends_on           = [aws_s3_bucket_policy.logs]
}
resource "aws_lambda_function" "api" {
  function_name                  = "${var.prefix}-events"
  role                           = aws_iam_role.app.arn
  filename                       = var.lambda_zip
  handler                        = "index.handler"
  runtime                        = "nodejs22.x"
  reserved_concurrent_executions = 5
  timeout                        = 10
  tracing_config { mode = "Active" }
}
resource "aws_ecr_repository" "images" {
  name                 = "${var.prefix}-images"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.bank.arn
  }
}
resource "aws_ebs_volume" "data" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 4
  type              = "gp3"
  encrypted         = true
  kms_key_id        = aws_kms_key.bank.arn
}

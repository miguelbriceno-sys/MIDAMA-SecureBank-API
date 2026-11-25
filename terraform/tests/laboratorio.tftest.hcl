mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = { names = ["us-east-1a", "us-east-1b"] }
  }
  mock_data "aws_caller_identity" {
    defaults = { account_id = "111111111111", arn = "arn:aws:iam::111111111111:role/laboratorio" }
  }
}
variables {
  ami        = "ami-0123456789abcdef0"
  lambda_zip = "funcion.zip"
}
run "plan_del_laboratorio" {
  command = plan
  assert {
    condition     = aws_db_instance.postgres.storage_encrypted && !aws_db_instance.postgres.publicly_accessible
    error_message = "La base requiere cifrado y red privada."
  }
}

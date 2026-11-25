terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
  }
}
provider "aws" {
  region = var.region
  default_tags {
    tags = { Proyecto = "SecureBank", Entorno = "laboratorio" }
  }
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "prefix" {
  type    = string
  default = "midama-securebank"
}
variable "ami" {
  type        = string
  description = "AMI aprobada para la región del laboratorio."
}
variable "lambda_zip" {
  type        = string
  description = "Ruta del ZIP de la función aprobado para el entorno."
}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" { state = "available" }
locals {
  account = data.aws_caller_identity.current.account_id
  names   = ["backups", "logs"]
}

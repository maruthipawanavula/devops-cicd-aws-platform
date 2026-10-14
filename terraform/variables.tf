variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as a prefix for all resources"
  type        = string
  default     = "cicd-sample"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across"
  type        = number
  default     = 2
}

variable "container_port" {
  description = "Port the sample service listens on"
  type        = number
  default     = 8080
}

variable "container_image" {
  description = "Container image to run. Defaults to the ECR repository URL with the 'latest' tag once the first image is pushed."
  type        = string
  default     = ""
}

variable "task_cpu" {
  description = "Fargate task CPU units (256, 512, 1024, ...)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of Fargate tasks to run"
  type        = number
  default     = 2
}

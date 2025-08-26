variable "vpc_id" {
  type = string
}

variable "tg_name" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "listener_arn" {
  type = string
}

variable "priority" {
  type = number
}

variable "host_headers" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}
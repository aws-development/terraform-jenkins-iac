variable "AWS_ACCESS_KEY" {
  type = string
}
variable "AWS_SECRET_KEY" {
  type = string
}
variable "REGION" {
  type    = string
  default = "ap-south-1"
}


variable "lob" {
  type        = string
  default     = "jenkins"
  description = "lob tag"
}

variable "tf_provider" {
  type        = string
  default     = "aws"
  description = "provider tag"
}

variable "env" {
  type        = string
  default     = "jenkins-poc"
  description = "env tag"
}

variable "platform" {
  type        = string
  default     = "playpen"
  description = "platform tag"
}

variable "application" {
  type        = string
  default     = "sandbox-app-jenkins"
  description = "application tag"
}

variable "cost_center" {
  type        = string
  default     = "aws-cc"
  description = "cost_center tag"
}

variable "owner" {
  type        = string
  default     = "ravikumar"
  description = "owner tag"
}




variable "instance_count" {
  type    = number
  default = 1
}

variable "ami_id" {
  type    = string
  default = "ami-006dcf34c09e50022"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "key_name" {
  type    = string
  default = "jenkins-key"
}

variable "subnet_id" {
  type    = string
  default = "subnet-0d158d777e97c4237"
}

variable "security_group_ids" {
  type    = list(string)
  default = ["sg-12345678"]
}

variable "user_data_file" {
  type    = string
  default = "userdata.sh"
}

variable "instance_tags" {
  type = map(string)
  default = {
    Name = "jenkins-instance"
  }
}

variable "public_key_path" {
  type    = string
  default = "C:\Users\ravikumar4\Documents\CONTAINER-LFC-WIZ-POC-1\jenkins-key.pub"
}

variable "private_key_path" {
  type    = string
  default = "C:\Users\ravikumar4\Documents\CONTAINER-LFC-WIZ-POC-1\jenkins-key.ppk"
}

variable "features" {
  description = "Feature toggle options"
  type        = map(bool)
  default = {
    diskfull = false
    cwagent  = true
    envoy    = false
  }
}

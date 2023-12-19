
data "template_file" "userdata" {
  template = file(var.user_data_file)
}
/*
resource "aws_key_pair" "ssm" {
  key_name   = var.key_name
  public_key = var.public_key_path
}
*/
/*
resource "local_file" "ssh_key" {
  filename = var.public_key_path
  content  = aws_key_pair.ssm.public_key
}
*/
resource "aws_instance" "ssm" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "jenkins-key"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.ssm_sg.id]
  user_data              = data.template_file.userdata.rendered

  #tags = var.instance_tags

  tags = {
    Name        = "ssm-instance-${count.index + 1}"
    env         = "playpen"
    envoy       = "enabled"
    COUNTRY     = "IN"
    ENVIRONMENT = "COPY"
  }

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
}

#output "private_key_path" {
#  value = aws_key_pair.ssm.private_key
#}


# Create a security group
resource "aws_security_group" "ssm_sg" {
  name_prefix = "jenkins-sg"
  description = "jenkins security group"
  vpc_id = "vpc-056f6058409ea6634"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.36.144.255/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["49.36.144.255/32"]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["49.36.144.255/32"]
    #cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    #cidr_blocks = ["49.36.144.255/32"]
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# Create an IAM instance profile for SSM
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_profile"

  #role = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  role = aws_iam_role.ssm_role.name

}



# Create an IAM role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      }

    ]
  })
}

# Attach the SSM policy to the IAM role
resource "aws_iam_role_policy_attachment" "ssm_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMManagedInstanceCore"
  role = aws_iam_role.ssm_role.name
}


resource "aws_ssm_association" "ssm_association" {
  name = "AWS-UpdateSSMAgent"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.ssm[0].id]
  }
}



resource "aws_ssm_document" "diskfull" {
  name            = "Run-Disk-Stress"
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/diskfull.yaml")
}

resource "aws_ssm_document" "cwagent" {
  name            = "Install-CloudWatch-Agent"
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/cwagent.yaml")
}
/*
resource "aws_ssm_document" "envoy" {
  name            = "Install-EnvoyProxy"
  document_format = "YAML"
  document_type   = "Command"
  content         = file(join("/", [path.module, "templates", "envoy.yaml"]))
}
*/
resource "aws_ssm_association" "cwagent" {
  for_each         = toset(lookup(var.features, "cwagent", false) ? ["enabled"] : [])
  name             = aws_ssm_document.cwagent.name
  association_name = "Install-CloudWatchAgent"
  targets {
    key    = "tag:env"
    values = ["playpen"]
  }
}

resource "time_sleep" "wait" {
  depends_on      = [aws_ssm_association.cwagent]
  create_duration = "15s"
}

resource "aws_ssm_association" "diskfull" {
  for_each         = toset(lookup(var.features, "diskfull", false) ? ["enabled"] : [])
  depends_on       = [time_sleep.wait]
  name             = aws_ssm_document.diskfull.name
  association_name = "Run-Disk-Stress-Test"
  parameters = {
    DurationSeconds = "60"
    Workers         = "4"
    Percent         = "70"
  }
  targets {
    key    = "tag:env"
    values = ["playpen"]
  }
}

/*
resource "aws_ssm_association" "envoy" {
  for_each         = toset(lookup(var.features, "envoy", false) ? ["enabled"] : [])
  depends_on       = [time_sleep.wait]
  name             = aws_ssm_document.envoy.name
  association_name = "Install-EnvoyProxy"
  parameters = {
    region       = var.region
    mesh         = "app"
    vnode        = "service"
    envoyVersion = "v1.23.1.0"
    appPort      = "80"
  }
  targets {
    key    = "tag:envoy"
    values = ["enabled"]
  }
}

*/

/*
# Create an SSM association for Host Management
resource "aws_ssm_association" "ssm_association" {
  #for_each = aws_instance.ssm
  name          = "ssm_association"
  instance_id   =  aws_instance.ssm[0].id
  #association_type = "ManagedInstance"
  parameters = {
    ComplianceDocumentVersion = "1.0"
    ComplianceType             = "AWS:InSpec"
    ContentHash                = "ABCDEF123456"
    DocumentName               = "AWS-ConfigureAWSEC2Instance"
    InstanceId                 =  aws_instance.ssm[0].id
    PlatformType               = "Linux"
    SsmComplianceDocumentName  = "AWS:InSpec Rules"
  }
}
*/

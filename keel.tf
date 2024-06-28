resource "kubernetes_namespace" "keel" {
  metadata {
    name = "keel"
  }
}

resource "aws_iam_role" "keel_role" {
  name = "KeelRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "keel_policy" {
  name = "KeelPolicy"
  role = aws_iam_role.keel_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:*",
          "ec2:*"
        ],
        Resource = "*"
      }
    ]
  })
}

data "aws_ssm_parameter" "access_key" {
  name = var.access_key_id
}

data "aws_ssm_parameter" "secret_key" {
  name = var.secret_access_key
}

variable "access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
  default     = "/infra/external_access_key_id"
}

variable "secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
  default     = "/infra/external_secret_key"
}

# resource "kubernetes_secret" "ecr_credentials" {
#   metadata {
#     name      = "keel-aws-ecr-credentials"
#     namespace = "keel"
#   }

#   type = "Opaque"
#   data = {
#     "aws_access_key_id"     = data.aws_ssm_parameter.access_key.value
#     "aws_secret_access_key" = data.aws_ssm_parameter.secret_key.value    
#     "aws_region"            = "us-east-1"
#   }
# }

resource "helm_release" "keel" {
  name       = "keel"
  repository = "https://charts.keel.sh"
  chart      = "keel"
  namespace  = kubernetes_namespace.keel.metadata[0].name

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "aws.region"
    value = "us-east-1"
  }

  set {
    name  = "image.tag"
    value = "latest"
  }

  set {
    name  = "watchNamespaces[0]"
    value = "name1"
  }

  set {
    name  = "watchNamespaces[1]"
    value = "name12"
  }

  set {
    name  = "watchNamespaces[2]"
    value = "name13"
  }

  set {
    name  = "ecr.region"
    value = "us-east-1"
  }

  set {
    name  = "ecr.enabled"
    value = "true"
  }

  set {
    name  = "ecr.accessKeyId"
    value = data.aws_ssm_parameter.access_key.value
  }

  set {
    name  = "ecr.secretAccessKey"
    value = data.aws_ssm_parameter.secret_key.value
  }

  set {
    name  = "ecr.roleArn"
    value = aws_iam_role.keel_role.arn
  }

  set {
    name  = "polling.enabled"
    value = "true"
  }

  set {
    name  = "polling.defaultSchedule"
    value = "@every 1m"
  }

  set {
    name  = "rbac.enabled"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "notificationLevel"
    value = "info"
  }

  set {
    name  = "basicauth.enabled"
    value = "true" 
  }
  set {
    name  = "basicauth.user"
    value = "admin"  
  }

  set {
    name  = "basicauth.password"
    value = "admin" 
  }

  set {
    name  = "podAnnotations.iam\\.amazonaws\\.com/role"
    value = "arn:aws:iam::<XXXXXXXX>:user/KeelRole"  
  }    
  }  
resource "aws_elastic_beanstalk_application" "tftest" {
  name        = "tf-test-app"
  description = "tf-test-app description"
}

# 기존 IAM Role 가져오기 (Data Source 사용)
data "aws_iam_role" "ec2_admin_role" {
  name = "_ec2_admin"
}

resource "aws_iam_instance_profile" "ec2_admin_profile" {
  name = "_ec2_admin"
  role = data.aws_iam_role.ec2_admin_role.name  # 기존 역할의 이름을 사용
}

resource "aws_elastic_beanstalk_environment" "tfenv" {
  name                = "tf-test-env"
  application         = aws_elastic_beanstalk_application.tftest.name
  solution_stack_name = "64bit Amazon Linux 2 v5.8.4 running Node.js 16"
  tier                = "WebServer::Standard::1.0"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.ec2_admin_profile.name # _ec2_admin 인스턴스 프로파일
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

    setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "Test"
    value     = "value"
  }
    setting {
      namespace = "aws:autoscaling:asg"
      name = "MinSize"
      value = "1"
    }
    setting {
      namespace = "aws:autoscaling:asg"
      name = "MaxSize"
      value = "4"
    }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "AllAtOnce"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "Timeout"
    value     = "600"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "default"
  }
  setting {
      namespace = "aws:elasticbeanstalk:healthreporting:system"
      name      = "SystemType"
      value     = "enhanced"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = "aws-elasticbeanstalk-service-role"
  }
    setting {
        namespace = "aws:ec2:vpc"
        name      = "VPCId"
        value     = ""
    }
    setting {
        namespace = "aws:ec2:vpc"
        name = "Subnets"
        value = ""
    }
    setting {
       namespace = "aws:ec2:vpc"
       name = "AssociatePublicIpAddress"
       value = "false"
    }
    setting {
        namespace = "aws:ec2:vpc"
        name      = "ELBScheme"
        value     = "public"
    }
    setting {
        namespace = "aws:ec2:vpc"
        name = "ELBSubnets"
        value = ""
    }
}
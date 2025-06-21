resource "aws_lb_target_group" "sapper" {
  name       = "sapper-asg"
  port       = var.port
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform_key_aws"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdMpuqqb4ncWZH0PevWFAzMp2+EwSOKPEk/0mir6OjvmvwhUJYFj/B6kJhp00kylXDfn/F2sUrVwI2tN1VNvN/ztMewauQzn+sFHeDjwAAktu7/rzxd7/36iHh1HTLdqUCs/h5DdbLtKlpQTNRhS04Bq639Gui4g+A87KM+bEVHQV/kUcpRSdTdnxfA2Lh8OF9dAD2FtlyCAE0Z1YUTvlfOWRdMpdoIFXiZ1uirb4XM0iQ4Ikpmb5Pk8n0dEnyR9FdOSCi5iH5S/hovKsbTy9sA0zQ/s1k+uiuYc6K4dohRo1cWOKarfi9MsFIcQtdGwQeVpuKo4j2mzeV5y8AmWNL enesshe@optimus"
}

resource "aws_launch_configuration" "sapper" {
  image_id        = var.image
  instance_type   = var.flavor
  user_data       = file("./user-data.sh")
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.terraform_instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "sapper" {
  min_size         = 1
  max_size         = 2
  desired_capacity = 1
  tag {
    key                 = "Name"
    value               = "terraform-aws-asg"
    propagate_at_launch = true
  }
  name_prefix          = "terraform-aws-asg-"
  launch_configuration = aws_launch_configuration.sapper.name
  vpc_zone_identifier  = [aws_subnet.public_subnet1.id]
}

resource "aws_autoscaling_policy" "web_cluster_target_tracking_policy" {
  name                      = "staging-web-cluster-target-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.sapper.name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}


resource "aws_lb" "sapper" {
  name               = "sapper-asg-terraform-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraform_lb.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

resource "aws_lb_listener" "terraform" {
  load_balancer_arn = aws_lb.sapper.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform.arn
  }
}


resource "aws_lb_target_group" "terraform" {
  name     = "sapper-asg-terraform"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_autoscaling_attachment" "terraform" {
  autoscaling_group_name = aws_autoscaling_group.sapper.id
  lb_target_group_arn    = aws_lb_target_group.terraform.arn
}


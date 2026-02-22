resource "aws_lb_target_group" "sherif" {
  name       = "sherif-asg"
  port       = var.port
  protocol   = "HTTP"
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]
}

resource "aws_key_pair" "deployer" {
  key_name   = "terraform_key_aws"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICE+RP6YdIgHxxJbip+WoftJOYO0GLjqSt4N9kZSkbwb enesshe@megatron"
}

resource "aws_launch_template" "sherif" {
  name_prefix   = "sherif-launch-template-"
  image_id      = var.image
  instance_type = var.flavor
  key_name      = aws_key_pair.deployer.key_name
  user_data     = base64encode(file("./user-data.sh"))

  vpc_security_group_ids = [aws_security_group.terraform_instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "sherif" {
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  name_prefix         = "terraform-aws-asg-"
  vpc_zone_identifier = [aws_subnet.public_subnet1.id]

  launch_template {
    id      = aws_launch_template.sherif.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "terraform-aws-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "web_cluster_target_tracking_policy" {
  name                      = "staging-web-cluster-target-tracking-policy"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.sherif.name
  estimated_instance_warmup = 200

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}


resource "aws_lb" "sherif" {
  name               = "sherif-asg-terraform-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraform_lb.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
}

resource "aws_lb_listener" "terraform" {
  load_balancer_arn = aws_lb.sherif.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terraform.arn
  }
}


resource "aws_lb_target_group" "terraform" {
  name     = "sherif-asg-terraform"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_autoscaling_attachment" "terraform" {
  autoscaling_group_name = aws_autoscaling_group.sherif.id
  lb_target_group_arn    = aws_lb_target_group.terraform.arn
}


resource "aws_elb" "elb" {
  name    = "terraform-elb"
  subnets = ["${aws_subnet.eu-central-1a-public.id}", "${aws_subnet.eu-central-1b-public.id}"]

  access_logs {
    bucket        = "task7-trail-bucket22"
    bucket_prefix = ""
    interval      = 60
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.nginx_aws.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "terraform-elb"
  }
}


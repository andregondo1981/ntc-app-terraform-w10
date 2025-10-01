//target group
resource "aws_lb_target_group" "tg1" {
    name     = "ntc-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.my-vpc.id
    target_type        = "instance"

    health_check {
        enabled = true
        interval            = 10
        path                = "/"
        port = "traffic-port"
        protocol            = "HTTP"
        timeout             = 6
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = 200
    }
    
    tags = {
        Name = "ntc-tg"
    }
    depends_on = [ aws_vpc.my-vpc ]
}

//attach ec2 instances to target group

resource "aws_lb_target_group_attachment" "name1" {
    target_group_arn = aws_lb_target_group.tg1.arn
  target_id = aws_instance.server1.id 
  port = 80
}
resource "aws_lb_target_group_attachment" "name2" {
    target_group_arn = aws_lb_target_group.tg1.arn
  target_id = aws_instance.server2.id 
  port = 80
}
// application load balancer

resource "aws_lb" "name" {
  name = "ntc-alb"
  internal = false 
  load_balancer_type = "application"  # string
  security_groups = [ aws_security_group.alb_sg.id ]
  subnets = [ aws_subnet.public1.id, aws_subnet.public2.id ]
  enable_deletion_protection = false // boolean
}
resource "aws_lb_listener" "listenner1" {
  load_balancer_arn = aws_lb.name.arn 
  port = 80 
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
}
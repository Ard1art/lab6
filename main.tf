provider "aws"{
    region = "us-east-1"
    access_key = "****************"
    secret_key = "****************************"
}

#SECURITYGROUP
#SECURITYGROUP
#SECURITYGROUP

resource "aws_security_group" "Lab6" {
    name = "Lab6"
    vpc_id = "vpc-1c5b8661"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lab6"
  }
}

#LOADBALANCER
#LOADBALANCER
#LOADBALANCER

resource "aws_lb" "ElbLab6" {
  name = "ElbLab6"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.Lab6.id ]
  subnets = [ "subnet-4bc6462d", "subnet-ee0dd9df" ]

  tags = {
    Name = "ElbLab6"
  }
}

resource "aws_lb_target_group" "TgElb" {
  name     = "Lab6-Target-Group"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id = "vpc-1c5b8661"
}

resource "aws_lb_target_group_attachment" "TgAttach" {
  target_group_arn = aws_lb_target_group.TgElb.arn
  count = length(aws_instance.webServer)
  target_id = aws_instance.webServer[count.index].id
  port = 80
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.ElbLab6.arn
    port = 80
    protocol = "HTTP"

  default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.TgElb.arn
    }
  }

#INSTANCES
#INSTANCES
#INSTANCES

resource "aws_instance" "webServer" {
  count = 2
  ami = "ami-0790f8745fe3811a2"
  instance_type =  "t2.micro"
  key_name = "ArturKey"
  disable_api_termination = true
  security_groups = [ aws_security_group.Lab6.name ]

  user_data = file("apach.sh")

  tags = {
     Name = format("lab6-i-%d", count.index)
   }

}

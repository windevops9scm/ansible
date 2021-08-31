resource "aws_spot_instance_request" "cheap_worker" {
  count                = local.LENGTH
  ami                  = "ami-074df373d6bafa625"
  spot_price           = "0.0031"
  instance_type        = "t3.micro"
  vpc_security_group_ids = ["sg-02206e75f89f8a0e4"]
  wait_for_fulfillment = true

  tags                 = {
    Name               = element(var.COMPONENTS,count.index )
  }
}

resource "aws_ec2_tag" "name-tag" {
  count                 = local.LENGTH
  resource_id           = element(aws_spot_instance_request.cheap_worker.*.spot_instance_id, count.index)
  key                   = "Name"
  value                 = element(var.COMPONENTS,count.index )
}

resource "aws_route53_record" "records" {
  count = local.LENGTH
  name = element(var.COMPONENTS, count.index)
  type = "A"
  zone_id = "Z020431433IWCUP7LS47Q"
  ttl = 300
  records = [element(aws_spot_instance_request.cheap_worker.*.private_ip, count.index )]
}

locals {
  LENGTH  = length(var.COMPONENTS)
}

resource "local_file" "inventory-file" {
  content     = "[FRONTEND]\n${aws_spot_instance_request.cheap_worker.*.private_ip[9]}\n[PAYMENT]\n${aws_spot_instance_request.cheap_worker.*.private_ip[8]}\n[SHIPPING]\n${aws_spot_instance_request.cheap_worker.*.private_ip[7]}\n[USER]\n${aws_spot_instance_request.cheap_worker.*.private_ip[6]}\n[CATALOGUE]\n${aws_spot_instance_request.cheap_worker.*.private_ip[5]}\n[CART]\n${aws_spot_instance_request.cheap_worker.*.private_ip[4]}\n[REDIS]\n${aws_spot_instance_request.cheap_worker.*.private_ip[3]}\n[RABBITMQ]\n${aws_spot_instance_request.cheap_worker.*.private_ip[2]}\n[MONGODB]\n${aws_spot_instance_request.cheap_worker.*.private_ip[1]}\n[MYSQL]\n${aws_spot_instance_request.cheap_worker.*.private_ip[0]}\n"
  filename    = "/tmp/inv-roboshop"
}

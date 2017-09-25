resource "aws_vpc" "wordpress" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags                 = "${merge(var.default_tags, map("Name", var.name))}"
}

resource "aws_internet_gateway" "wordpress" {
  vpc_id = "${aws_vpc.wordpress.id}"
  tags   = "${merge(var.default_tags, map("Name", var.name))}"
}

resource "aws_eip" "nat" {
    vpc = true
}

resource "aws_nat_gateway" "gw" {
    allocation_id = "${aws_eip.nat.id}"
    depends_on    = ["aws_internet_gateway.wordpress"]
    subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.wordpress.id}"
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = "${aws_internet_gateway.wordpress.id}"
  }
  tags            = "${merge(var.default_tags, map("Name", var.name))}" 
}

resource "aws_route_table_association" "public" {
  count           = "${length(compact(split(",", var.public_subnets)))}"
  subnet_id       = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id  = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.wordpress.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }
  tags = "${merge(var.default_tags, map("Name", var.name))}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(compact(split(",", var.private_subnets)))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.wordpress.id}"
  cidr_block        = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(compact(split(",", var.private_subnets)))}"
  tags = "${merge(var.default_tags, map("Name", var.name))}"
}

resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.wordpress.id}"
  cidr_block        = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(compact(split(",", var.public_subnets)))}"
  tags = "${merge(var.default_tags, map("Name", var.name))}"
  map_public_ip_on_launch = true
}


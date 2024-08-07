# VPC and Subnets
resource "yandex_vpc_network" "vpc" {
  name = "vpc-mysql-mdb-multi"
}

resource "yandex_vpc_subnet" "sub_a" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "sub_b" {
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

# Security Group
resource "yandex_vpc_security_group" "db_sg" {
  name        = "sg-mysql"
  description = "mysql security group"
  network_id  = yandex_vpc_network.vpc.id

  ingress {
    protocol       = "TCP"
    description    = "incoming-mongodb"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 27018
  }

  egress {
    protocol       = "ANY"
    description    = "outgoing-all"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}

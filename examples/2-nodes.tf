module "mongo" {
  source = "../"

  security_groups_ids_list = [yandex_vpc_security_group.db_sg.id, ]

  network_id = yandex_vpc_network.vpc.id

  hosts_definition = [
    {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.sub_a.id
    },
    {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.sub_b.id
    },
  ]

  databases = [{ "name" : "test1" }]

  users = [
    {
      name        = "test1-owner"
      permissions = [{ "database_name" : "test1" }]
  }, ]

  mongod = [{
    net = [{
      compressors              = ["snappy"]
      max_incoming_connections = 10
    }]
  }]

  maintenance_window = {
    type : "ANYTIME"
  }

}

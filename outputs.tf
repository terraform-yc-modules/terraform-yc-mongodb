output "cluster_id" {
  description = "MongoDB cluster ID"
  value       = yandex_mdb_mongodb_cluster.this.id
}

output "cluster_name" {
  description = "MongoDB cluster name"
  value       = yandex_mdb_mongodb_cluster.this.name
}

output "cluster_host_names_list" {
  description = "MongoDB cluster host name"
  value       = [yandex_mdb_mongodb_cluster.this.host[*].name]
}

output "users_data" {
  sensitive   = true
  description = "A list of users with passwords."
  value = [
    for u in yandex_mdb_mongodb_user.user : {
      user     = u["name"]
      password = u["password"]
    }
  ]
}

output "databases" {
  description = "A list of databases names."
  value       = [for db in var.databases : db.name]
}

output "connection_step_1" {
  description = "1 step - Install certificate"
  value       = "mkdir -p ~/.mongodb && curl -fsL 'https://storage.yandexcloud.net/cloud-certs/CA.pem' -o ~/.mongodb/root.crt && chmod 0644 ~/.mongodb/root.crt"
}

output "connection_step_2" {
  description = <<EOF
    How connect to MongoDB cluster?

    1. Run connection string from the output value, for example
    
      mongosh --norc \
        --tls \
        --tlsCAFile /home/<домашняя_директория>/.mongodb/root.crt \
        --host '<FQDN_хоста_1_MongoDB>:27018,...,<FQDN_хоста_N_MongoDB>:27018' \
        --username <имя_пользователя_БД> \
        --password <пароль_пользователя_БД> \
        <имя_БД>
  EOF
  value       = "mongosh --norc --tls --tlsCAFile /home/<домашняя_директория>/.mongodb/root.crt --host '<FQDN_хоста_1_MongoDB>:27018,...,<FQDN_хоста_N_MongoDB>:27018' --username <имя_пользователя_БД> --password <пароль_пользователя_БД> <имя_БД>"
}

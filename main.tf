### Datasource
data "yandex_client_config" "client" {}

### Locals
locals {
  folder_id = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
}

resource "yandex_mdb_mongodb_cluster" "this" {
  name                = var.name
  description         = var.description
  environment         = var.environment
  folder_id           = local.folder_id
  labels              = var.labels
  network_id          = var.network_id
  security_group_ids  = var.security_groups_ids_list
  deletion_protection = var.deletion_protection

  cluster_config {
    version                       = var.mongodb_version
    backup_retain_period_days     = var.backup_retain_period_days
    feature_compatibility_version = var.feature_compatibility_version

    dynamic "access" {
      for_each = range(var.access_policy == null ? 0 : 1)
      content {
        data_lens     = var.access_policy.data_lens
        data_transfer = var.access_policy.data_transfer
      }
    }
    dynamic "performance_diagnostics" {
      for_each = range(var.performance_diagnostics == null ? 0 : 1)
      content {
        enabled = var.performance_diagnostics.enabled
      }
    }
    dynamic "backup_window_start" {
      for_each = range(var.backup_window_start == null ? 0 : 1)
      content {
        hours   = var.backup_window_start.hours
        minutes = var.backup_window_start.minutes
      }
    }

    dynamic "mongod" {
      for_each = var.mongod
      content {
        dynamic "security" {
          for_each = mongod.value.security
          content {
            enable_encryption = security.value.enable_encryption
            dynamic "kmip" {
              for_each = security.value.kmip
              content {
                server_name        = kmip.value.server_name
                port               = kmip.value.port
                server_ca          = kmip.value.server_ca
                client_certificate = kmip.value.client_certificate
                key_identifier     = kmip.value.key_identifier
              }
            }
          }
        }
        dynamic "audit_log" {
          for_each = mongod.value.audit_log
          content {
            filter                = audit_log.value.filter
            runtime_configuration = audit_log.runtime_configuration
          }
        }

        dynamic "operation_profiling" {
          for_each = mongod.value.operation_profiling
          content {
            mode                = operation_profiling.value.mode
            slow_op_threshold   = operation_profiling.value.slow_op_threshold
            slow_op_sample_rate = _profiling.value.slow_op_sample_rate
          }
        }

        dynamic "net" {
          for_each = mongod.value.net
          content {
            max_incoming_connections = net.value.max_incoming_connections
            compressors              = net.value.compressors
          }
        }

        dynamic "storage" {
          for_each = mongod.value.storage
          content {
            dynamic "wired_tiger" {
              for_each = storage.value.wired_tiger
              content {
                cache_size_gb      = wired_tiger.value.cache_size_gb
                block_compressor   = wired_tiger.value.block_compressor
                prefix_compression = wired_tiger.value.prefix_compression
              }
            }
            dynamic "journal" {
              for_each = storage.value.journal
              content {
                commit_interval = journal.value.commit_interval
              }
            }
          }
        }
      }
    }

    dynamic "mongos" {
      for_each = var.mongos
      content {
        dynamic "net" {
          for_each = mongos.value.net
          content {
            max_incoming_connections = net.value.max_incoming_connections
            compressors              = net.value.compressors
          }
        }
      }
    }
    dynamic "mongocfg" {
      for_each = var.mongocfg
      content {
        dynamic "operation_profiling" {
          for_each = mongocfg.value.operation_profiling
          content {
            mode              = operation_profiling.value.mode
            slow_op_threshold = operation_profiling.value.slow_op_threshold
            # slow_op_sample_rate = operation_profiling.value.slow_op_sample_rate
          }
        }

        dynamic "net" {
          for_each = mongocfg.value.net
          content {
            max_incoming_connections = net.value.max_incoming_connections
          }
        }

        # dynamic "storage" {
        #   for_each = mongocfg.value.storage
        #   content {
        #     dynamic "journal" {
        #       for_each = storage.value.journal
        #       content {
        #         commit_interval = journal.value.commit_interval
        #       }
        #     }
        #   }
        # }
      }
    }
  }

  dynamic "host" {
    for_each = var.hosts_definition
    content {
      zone_id          = host.value.zone_id
      role             = host.value.role
      subnet_id        = host.value.subnet_id
      assign_public_ip = host.value.assign_public_ip
      shard_name       = host.value.shard_name
      type             = host.value.type
      dynamic "host_parameters" {
        for_each = host.value.host_parameters
        content {
          hidden               = host_parameters.value.hidden
          priority             = host_parameters.value.priority
          secondary_delay_secs = host_parameters.value.secondary_delay_secs
          tags                 = host_parameters.value.tags
        }
      }
    }
  }

  resources_mongod {
    resource_preset_id = var.resources_mongod.resource_preset_id
    disk_size          = var.resources_mongod.disk_size
    disk_type_id       = var.resources_mongod.disk_type_id
  }

  resources_mongos {
    resource_preset_id = var.resources_mongos.resource_preset_id
    disk_size          = var.resources_mongos.disk_size
    disk_type_id       = var.resources_mongos.disk_type_id
  }

  resources_mongocfg {
    resource_preset_id = var.resources_mongocfg.resource_preset_id
    disk_size          = var.resources_mongocfg.disk_size
    disk_type_id       = var.resources_mongocfg.disk_type_id
  }
  resources_mongoinfra {
    resource_preset_id = var.resources_mongoinfra.resource_preset_id
    disk_size          = var.resources_mongoinfra.disk_size
    disk_type_id       = var.resources_mongoinfra.disk_type_id
  }
  dynamic "restore" {
    for_each = range(var.restore_parameters == null ? 0 : 1)
    content {
      backup_id = var.restore_parameters.backup_id
      time      = var.restore_parameters.time
    }
  }

  dynamic "maintenance_window" {
    for_each = range(var.maintenance_window == null ? 0 : 1)
    content {
      type = var.maintenance_window.type
      day  = var.maintenance_window.day
      hour = var.maintenance_window.hour
    }
  }
}

## Databases
resource "yandex_mdb_mongodb_database" "this" {
  for_each = length(var.databases) > 0 ? { for db in var.databases : db.name => db } : {}

  cluster_id = yandex_mdb_mongodb_cluster.this.id
  name       = lookup(each.value, "name", null)
}

##Users
resource "random_password" "password" {
  for_each         = { for v in var.users : v.name => v if v.password == null }
  length           = 16
  special          = true
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_"
}

resource "yandex_mdb_mongodb_user" "user" {
  for_each = length(var.users) > 0 ? { for user in var.users : user.name => user } : {}

  cluster_id = yandex_mdb_mongodb_cluster.this.id
  name       = each.value.name
  password   = each.value.password == null ? random_password.password[each.value.name].result : each.value.password

  dynamic "permission" {
    for_each = lookup(each.value, "permissions", [])
    content {
      database_name = permission.value.database_name
      roles         = permission.value.roles
    }
  }

  depends_on = [
    yandex_mdb_mongodb_database.this
  ]
}

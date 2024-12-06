# Yandex Cloud Managed MongoDB Cluster

## Features

- Create a Managed MongoDB cluster with predefined number of DB hosts
- Create a list of users and databases with permissions
- Easy to use in other resources via outputs

## MongoDB cluster definition

At first you need to create VPC network with three subnets!

MongoDB module requires a following input variables:
 - VPC network id
 - VPC network subnets ids
 - MongoDB hosts definitions - a list of maps with DB host name, zone name and subnet id.
 - Databases - a list of databases with database name
 - Users - a list users with a list of grants to databases.

<b>Notes:</b>
1. `users` variable defines a list of separate db users with a `permissions` list, which indicates to a list of databases and grants for each of them. Default grant is the "read". 

### Example

See [examples section](./examples/)

### Configure Terraform for Yandex Cloud

- Install [YC CLI](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud

```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.134.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.134.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [yandex_mdb_mongodb_cluster.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mongodb_cluster) | resource |
| [yandex_mdb_mongodb_database.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mongodb_database) | resource |
| [yandex_mdb_mongodb_user.user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mongodb_user) | resource |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy"></a> [access\_policy](#input\_access\_policy) | Access policy from other services to the MongoDB cluster. | <pre>object({<br>    data_lens     = optional(bool, null)<br>    data_transfer = optional(bool, null)<br>  })</pre> | `{}` | no |
| <a name="input_backup_retain_period_days"></a> [backup\_retain\_period\_days](#input\_backup\_retain\_period\_days) | (Optional) The period in days during which backups are stored. | `number` | `7` | no |
| <a name="input_backup_window_start"></a> [backup\_window\_start](#input\_backup\_window\_start) | (Optional) Time to start the daily backup, in the UTC timezone. | <pre>object({<br>    hours   = string<br>    minutes = optional(string, "00")<br>  })</pre> | `null` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | A list of MongoDB databases.<br><br>    Required values:<br>      - name        - The name of the database. | <pre>list(object({<br>    name = string<br>  }))</pre> | `[]` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Inhibits deletion of the cluster. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | MongoDB cluster description | `string` | `"Managed MongoDB cluster created by terraform module"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment type: PRODUCTION or PRESTABLE | `string` | `"PRODUCTION"` | no |
| <a name="input_feature_compatibility_version"></a> [feature\_compatibility\_version](#input\_feature\_compatibility\_version) | MongoDB feature compatibility version | `string` | `""` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Folder id that contains the MongoDB cluster | `string` | `null` | no |
| <a name="input_hosts_definition"></a> [hosts\_definition](#input\_hosts\_definition) | A list of MongoDB hosts. | <pre>list(object({<br>    zone_id          = string<br>    role             = optional(string, null)<br>    subnet_id        = optional(string, null)<br>    assign_public_ip = optional(bool, false)<br>    shard_name       = optional(string, null)<br>    type             = optional(string, "mongod")<br>    host_parameters = optional(list(object({<br>      hidden               = optional(bool, null)<br>      priority             = optional(string, null)<br>      secondary_delay_secs = optional(number, null)<br>      tags                 = optional(any, null)<br>    })), [])<br>  }))</pre> | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of label pairs to assing to the MongoDB cluster. | `map(any)` | `{}` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) Maintenance policy of the MongoDB cluster.<br>      - type - (Required) Type of maintenance window. Can be either ANYTIME or WEEKLY. A day and hour of window need to be specified with weekly window.<br>      - day  - (Optional) Day of the week (in DDD format). Allowed values: "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"<br>      - hour - (Optional) Hour of the day in UTC (in HH format). Allowed value is between 0 and 23. | <pre>object({<br>    type = string<br>    day  = optional(string, null)<br>    hour = optional(string, null)<br>  })</pre> | <pre>{<br>  "type": "ANYTIME"<br>}</pre> | no |
| <a name="input_mongocfg"></a> [mongocfg](#input\_mongocfg) | Configuration for mongocfg instances | <pre>list(object({<br>    operation_profiling = optional(list(object({<br>      mode              = optional(string, null)<br>      slow_op_threshold = optional(number, null)<br>      # slow_op_sample_rate = optional(number,null)<br>    })), [])<br>    net = optional(list(object({<br>      max_incoming_connections = optional(number, null)<br>    })), [])<br>    storage = list(object({<br>      wired_tiger = optional(map(any), null)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_mongod"></a> [mongod](#input\_mongod) | Configuration for mongod instances | <pre>list(object({<br>    security = optional(list(object({<br>      enable_encryption = optional(bool, null)<br>      kmip              = optional(map(any), {})<br>    })), [])<br>    audit_log = optional(list(object({<br>      filter                = optional(string, null)<br>      runtime_configuration = optional(bool, null)<br>    })), [])<br>    set_parameter = optional(list(object({<br>      audit_authorization_success            = optional(bool, null)<br>      enable_flow_control                    = optional(bool, null)<br>      min_snapshot_history_window_in_seconds = optional(number, null)<br>    })), [])<br>    operation_profiling = optional(list(object({<br>      mode              = optional(string, null)<br>      slow_op_threshold = optional(number, null)<br>    })), [])<br>    net = optional(list(object({<br>      max_incoming_connections = optional(number, null)<br>      compressors              = optional(list(string), [])<br>    })), [])<br>    storage = optional(list(object({<br>      wired_tiger = optional(map(any), {})<br>      journal     = optional(map(any), {})<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_mongodb_version"></a> [mongodb\_version](#input\_mongodb\_version) | MongoDB version | `string` | `"6.0"` | no |
| <a name="input_mongos"></a> [mongos](#input\_mongos) | Configuration for mongos instances | <pre>list(object({<br>    net = list(object({<br>      max_incoming_connections = optional(number, null)<br>      compressors              = optional(list(string), [])<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of MongoDB cluster | `string` | `"mongodb-cluster"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | MongoDB cluster network id | `string` | n/a | yes |
| <a name="input_performance_diagnostics"></a> [performance\_diagnostics](#input\_performance\_diagnostics) | (Optional) MongoDB cluster performance diagnostics settings. | <pre>object({<br>    enabled = optional(bool, true)<br>  })</pre> | `{}` | no |
| <a name="input_resources_mongocfg"></a> [resources\_mongocfg](#input\_resources\_mongocfg) | Resources allocated to mongocfg hosts of the MongoDB cluster | <pre>object({<br>    resource_preset_id = optional(string, "s2.micro")<br>    disk_size          = optional(number, 40)<br>    disk_type_id       = optional(string, "network-ssd")<br>  })</pre> | `{}` | no |
| <a name="input_resources_mongod"></a> [resources\_mongod](#input\_resources\_mongod) | Resources allocated to mongod hosts of the MongoDB cluster | <pre>object({<br>    resource_preset_id = optional(string, "s2.micro")<br>    disk_size          = optional(number, 40)<br>    disk_type_id       = optional(string, "network-ssd")<br>  })</pre> | `{}` | no |
| <a name="input_resources_mongoinfra"></a> [resources\_mongoinfra](#input\_resources\_mongoinfra) | Resources allocated to mongoinfra hosts of the MongoDB cluster | <pre>object({<br>    resource_preset_id = optional(string, "s2.micro")<br>    disk_size          = optional(number, 40)<br>    disk_type_id       = optional(string, "network-ssd")<br>  })</pre> | `{}` | no |
| <a name="input_resources_mongos"></a> [resources\_mongos](#input\_resources\_mongos) | Resources allocated to mongos hosts of the MongoDB cluster | <pre>object({<br>    resource_preset_id = optional(string, "s2.micro")<br>    disk_size          = optional(number, 40)<br>    disk_type_id       = optional(string, "network-ssd")<br>  })</pre> | `{}` | no |
| <a name="input_restore_parameters"></a> [restore\_parameters](#input\_restore\_parameters) | The cluster will be created from the specified backup.<br>    NOTES:<br>      - backup\_id must be specified to create a new MongoDB cluster from a backup.<br>      - Time format is 'yyyy-mm-ddThh:mi:ss', where T is a delimeter, e.g. "2022-02-22T11:33:44". | <pre>object({<br>    backup_id = string<br>    time      = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_security_groups_ids_list"></a> [security\_groups\_ids\_list](#input\_security\_groups\_ids\_list) | A list of security group IDs to which the MongoDB cluster belongs | `list(string)` | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | This is a list for additional MongoDB users with own permissions. <br><br>    Required values:<br>      - name                  - The name of the user.<br>      - password              - (Optional) The user's password. If it's omitted a random password will be generated<br>      - permissions           - (Optional) A list of objects { databases\_name, grants[] } for an access.<br>                                'roles' is a optional list of permissions, the default values is ["read"] | <pre>list(object({<br>    name     = string<br>    password = optional(string, null)<br>    permissions = optional(list(object({<br>      database_name = string<br>      roles         = optional(list(string), ["read"])<br>    })), [])<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_host_names_list"></a> [cluster\_host\_names\_list](#output\_cluster\_host\_names\_list) | MongoDB cluster host name |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | MongoDB cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | MongoDB cluster name |
| <a name="output_connection_step_1"></a> [connection\_step\_1](#output\_connection\_step\_1) | 1 step - Install certificate |
| <a name="output_connection_step_2"></a> [connection\_step\_2](#output\_connection\_step\_2) | How connect to MongoDB cluster?<br><br>    1. Run connection string from the output value, for example<br><br>      mongosh --norc \<br>        --tls \<br>        --tlsCAFile /home/<домашняя\_директория>/.mongodb/root.crt \<br>        --host '<FQDN\_хоста\_1\_MongoDB>:27018,...,<FQDN\_хоста\_N\_MongoDB>:27018' \<br>        --username <имя\_пользователя\_БД> \<br>        --password <пароль\_пользователя\_БД> \<br>        <имя\_БД> |
| <a name="output_databases"></a> [databases](#output\_databases) | A list of databases names. |
| <a name="output_users_data"></a> [users\_data](#output\_users\_data) | A list of users with passwords. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

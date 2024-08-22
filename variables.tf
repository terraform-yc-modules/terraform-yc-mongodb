variable "name" {
  description = "Name of MongoDB cluster"
  type        = string
  default     = "mongodb-cluster"
}

variable "environment" {
  description = "Environment type: PRODUCTION or PRESTABLE"
  type        = string
  default     = "PRODUCTION"
  validation {
    condition     = contains(["PRODUCTION", "PRESTABLE"], var.environment)
    error_message = "Release channel should be PRODUCTION (stable feature set) or PRESTABLE (early bird feature access)."
  }
}

variable "network_id" {
  description = "MongoDB cluster network id"
  type        = string
}

variable "description" {
  description = "MongoDB cluster description"
  type        = string
  default     = "Managed MongoDB cluster created by terraform module"
}

variable "folder_id" {
  description = "Folder id that contains the MongoDB cluster"
  type        = string
  default     = null
}

variable "labels" {
  description = "A set of label pairs to assing to the MongoDB cluster."
  type        = map(any)
  default     = {}
}

variable "security_groups_ids_list" {
  description = "A list of security group IDs to which the MongoDB cluster belongs"
  type        = list(string)
  default     = []
  nullable    = true
}

variable "deletion_protection" {
  description = "Inhibits deletion of the cluster."
  type        = bool
  default     = false
}

variable "mongodb_version" {
  description = "MongoDB version"
  type        = string
  default     = "6.0"
  validation {
    condition     = contains(["5.0", "6.0", "6.0-enterprise"], var.mongodb_version)
    error_message = "Allowed MongoDB versions are 5.0, 6.0, 6.0-enterprise."
  }
}

variable "access_policy" {
  description = "Access policy from other services to the MongoDB cluster."
  type = object({
    data_lens     = optional(bool, null)
    data_transfer = optional(bool, null)
  })
  default = {}
}

variable "performance_diagnostics" {
  description = "(Optional) MongoDB cluster performance diagnostics settings."
  type = object({
    enabled = optional(bool, true)
  })
  default = {}
}

variable "backup_window_start" {
  description = "(Optional) Time to start the daily backup, in the UTC timezone."
  type = object({
    hours   = string
    minutes = optional(string, "00")
  })
  default = null
}

variable "maintenance_window" {
  description = <<EOF
    (Optional) Maintenance policy of the MongoDB cluster.
      - type - (Required) Type of maintenance window. Can be either ANYTIME or WEEKLY. A day and hour of window need to be specified with weekly window.
      - day  - (Optional) Day of the week (in DDD format). Allowed values: "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"
      - hour - (Optional) Hour of the day in UTC (in HH format). Allowed value is between 0 and 23.
  EOF
  type = object({
    type = string
    day  = optional(string, null)
    hour = optional(string, null)
  })
  default = {
    type = "ANYTIME"
  }
}

variable "backup_retain_period_days" {
  description = "(Optional) The period in days during which backups are stored."
  type        = number
  default     = 7
}

variable "feature_compatibility_version" {
  description = "MongoDB feature compatibility version"
  type        = string
  default     = ""
  validation {
    condition     = contains(["5.0", "6.0", ""], var.feature_compatibility_version)
    error_message = "Allowed MongoDB feature compatibility version are 5.0, 6.0."
  }
}

variable "restore_parameters" {
  description = <<EOF
    The cluster will be created from the specified backup.
    NOTES:
      - backup_id must be specified to create a new MongoDB cluster from a backup.
      - Time format is 'yyyy-mm-ddThh:mi:ss', where T is a delimeter, e.g. "2022-02-22T11:33:44".
  EOF
  type = object({
    backup_id = string
    time      = optional(string, null)
  })
  default = null
}

variable "hosts_definition" {
  description = "A list of MongoDB hosts."

  type = list(object({
    zone_id          = string
    role             = optional(string, null)
    subnet_id        = optional(string, null)
    assign_public_ip = optional(bool, false)
    shard_name       = optional(string, null)
    type             = optional(string, "mongod")
    host_parameters = optional(list(object({
      hidden               = optional(bool, null)
      priority             = optional(string, null)
      secondary_delay_secs = optional(number, null)
      tags                 = optional(any, null)
    })), [])
  }))
  #! не работает
  # validation {
  #   condition     = contains(["PRIMARY", "SECONDARY", null], var.hosts_definition[*].role)
  #   error_message = "Allowed MongoDB roles for host 'PRIMARY', 'SECONDARY'."
  # }
}

variable "resources_mongod" {
  description = "Resources allocated to mongod hosts of the MongoDB cluster"
  type = object({
    resource_preset_id = optional(string, "s2.micro")
    disk_size          = optional(number, 40)
    disk_type_id       = optional(string, "network-ssd")
  })
  default = {}
}

variable "resources_mongos" {
  description = "Resources allocated to mongos hosts of the MongoDB cluster"
  type = object({
    resource_preset_id = optional(string, "s2.micro")
    disk_size          = optional(number, 40)
    disk_type_id       = optional(string, "network-ssd")
  })
  default = {}
}

variable "resources_mongocfg" {
  description = "Resources allocated to mongocfg hosts of the MongoDB cluster"
  type = object({
    resource_preset_id = optional(string, "s2.micro")
    disk_size          = optional(number, 40)
    disk_type_id       = optional(string, "network-ssd")
  })
  default = {}
}
variable "resources_mongoinfra" {
  description = "Resources allocated to mongoinfra hosts of the MongoDB cluster"
  type = object({
    resource_preset_id = optional(string, "s2.micro")
    disk_size          = optional(number, 40)
    disk_type_id       = optional(string, "network-ssd")
  })
  default = {}
}

variable "databases" {
  description = <<EOF
    A list of MongoDB databases.

    Required values:
      - name        - The name of the database.
  EOF
  type = list(object({
    name = string
  }))
  default = []
}

variable "users" {
  description = <<EOF
    This is a list for additional MongoDB users with own permissions. 

    Required values:
      - name                  - The name of the user.
      - password              - (Optional) The user's password. If it's omitted a random password will be generated
      - permissions           - (Optional) A list of objects { databases_name, grants[] } for an access.
                                'roles' is a optional list of permissions, the default values is ["read"]
  EOF

  type = list(object({
    name     = string
    password = optional(string, null)
    permissions = optional(list(object({
      database_name = string
      roles         = optional(list(string), ["read"])
    })), [])
  }))
  default = []
}

#! проверть
variable "mongod" {
  description = "Configuration for mongod instances"
  type = list(object({
    security = optional(list(object({
      enable_encryption = optional(bool, null)
      kmip              = optional(map(any), {})
    })), [])
    audit_log = optional(list(object({
      filter                = optional(string, null)
      runtime_configuration = optional(bool, null)
    })), [])
    set_parameter = optional(list(object({
      audit_authorization_success            = optional(bool, null)
      enable_flow_control                    = optional(bool, null)
      min_snapshot_history_window_in_seconds = optional(number, null)
    })), [])
    operation_profiling = optional(list(object({
      mode                = optional(string, null)
      slow_op_threshold   = optional(number, null)
      slow_op_sample_rate = optional(number, null)
    })), [])
    net = optional(list(object({
      max_incoming_connections = optional(number, null)
      compressors              = optional(list(string), [])
    })), [])
    storage = optional(list(object({
      wired_tiger = optional(map(any), {})
      journal     = optional(map(any), {})
    })), [])
  }))
  default = []
}

variable "mongocfg" {
  description = "Configuration for mongocfg instances"
  type = list(object({
    operation_profiling = optional(list(object({
      mode              = optional(string, null)
      slow_op_threshold = optional(number, null)
      # slow_op_sample_rate = optional(number,null)
    })), [])
    net = optional(list(object({
      max_incoming_connections = optional(number, null)
    })), [])
    # storage = list(object({
    #   journal     = optional(map(any),null) 
    # }))
  }))
  default = []
}

variable "mongos" {
  description = "Configuration for mongos instances"
  type = list(object({
    net = list(object({
      max_incoming_connections = optional(number, null)
      compressors              = optional(list(string), [])
    }))
  }))
  default = []
}

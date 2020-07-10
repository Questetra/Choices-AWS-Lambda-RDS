resource "aws_rds_cluster" "sample-database-1" {
    cluster_identifier      = var.db_cluster_identifier
    master_username         = var.db_username
    master_password         = var.db_password
    storage_encrypted       = true
    copy_tags_to_snapshot   = true
    skip_final_snapshot     = true
    db_cluster_parameter_group_name = "paramgroup-for-utf8"
}

resource "aws_db_instance" "sample-database-1-instance-1" {
    identifier                = var.db_instance_identifier
    allocated_storage         = 1
    storage_type              = "aurora"
    engine                    = "aurora"
    engine_version            = "5.6.10a"
    instance_class            = var.db_instance_size
    publicly_accessible       = true
    vpc_security_group_ids    = [aws_security_group.default-vpc-sg.id]
    storage_encrypted         = true
    monitoring_interval       = 60
    performance_insights_enabled = true
    skip_final_snapshot       = true
}

resource "aws_rds_cluster_parameter_group" "paramgroup-for-utf8" {
    description = "DB Cluster Parameter Group for UTF-8 Encoding"
    family      = "aurora5.6"
    name        = "paramgroup-for-utf8"

    parameter {
        apply_method = "immediate"
        name         = "character_set_client"
        value        = "utf8"
    }
    parameter {
        apply_method = "immediate"
        name         = "character_set_connection"
        value        = "utf8"
    }
    parameter {
        apply_method = "immediate"
        name         = "character_set_database"
        value        = "utf8"
    }
    parameter {
        apply_method = "immediate"
        name         = "character_set_results"
        value        = "utf8"
    }
    parameter {
        apply_method = "immediate"
        name         = "character_set_server"
        value        = "utf8"
    }
    parameter {
        apply_method = "immediate"
        name         = "skip-character-set-client-handshake"
        value        = "1"
    }
}

output "db_endpoint" {
    value = aws_rds_cluster.sample-database-1.reader_endpoint
}
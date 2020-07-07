resource "aws_rds_cluster" "sample-database-1" {
    cluster_identifier      = var.db_cluster_identifier
    master_username         = var.db_username
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
    instance_class            = "db.t2.small"
    publicly_accessible       = true
    vpc_security_group_ids    = [aws_security_group.default-vpc-sg.id]
    // db_subnet_group_name      = "default-vpc-4e62ba25"
    storage_encrypted         = true
    monitoring_interval       = 60
    performance_insights_enabled = true
    skip_final_snapshot       = true
}

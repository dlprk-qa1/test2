##### AWS Aurora (PostgreSQL engine): 

module "aws-aurora-db" {
 source = "./databases/terraform-aws-rds-aurora/deploy"
}


##### DyanamoDB:


resource "aws_dynamodb_table" "safemarch-dynamodb-table" {
  name           = "Safemarch-card-processing-dev"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "CardNum"

  attribute {
    name = "CardNum"
    type = "S"
  }

  tags = {
    Name        = "safemarch-cardprocessing-cards"
    Environment = "dev"
  }
}

##### Redshift:

resource "aws_redshift_cluster" "safemarch-redshift" {
  cluster_identifier = "safemarch-redshift-cardprocessing-dev"
  database_name      = "safemarch_cards_processing_db"
  master_username    = "safemarchadmin"
  master_password    = "insecure_Password123"
  node_type          = "dc2.large"
  cluster_type       = "single-node"
}

##### MySql:

resource "aws_db_instance" "safemarch-mysql1" {
  allocated_storage    = 10
  identifier           = "safemarch-cardprocessing-cards"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "safemarchadmin"
  password             = "insecurePassword1"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}


##### Elastic Cache:

resource "aws_elasticache_cluster" "safemarch-cache" {
  cluster_id           = "safemarch-cardprocessing-frontend-cache"
  engine               = "memcached"
  node_type            = "cache.r6g.large"
  num_cache_nodes      = 1
  port                 = 11211
}

##### Neptune:

resource "aws_neptune_cluster" "safemarch-neptune" {
  cluster_identifier                  = "safemarch-cardprocessing-neptune-cluster"
  engine                              = "neptune"
  backup_retention_period             = 5
  preferred_backup_window             = "07:00-09:00"
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = true
  apply_immediately                   = true
}


##### Kinesis:

resource "aws_kinesis_stream" "safemarch-cardprocessing-stream" {
  name             = "safemarch-cardprocessing-stream-dev"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = "dev"
  }
}

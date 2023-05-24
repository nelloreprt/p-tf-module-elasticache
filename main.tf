# elasticache=redis >> Provides MULTI_END_POINT
# Steps to be followed in any data_base service of aws
#1. Cluster
#2. Subnet_groups
#3. -------Cluster_instance (not applicable for elaticache-redis)----------
# elasticache=redis >> Provides MULTI_END_POINT
# Our robot application is developed in such a way that
# it can provide with only ONE_END_POINT of REDIS
# >> so we have to go with  DISABLE CLUSTER_MODE



resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.env}-elasticache-redis-cluster"
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = var.port

  # E
  # referencing back the subnet_group to cluster
  subnet_group_name = aws_elasticache_subnet_group.main.name

  security_group_ids = [aws_security_group.main.id]
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.env}-elasticache-subnet-group-main"
  subnet_ids = var.subnet_ids
}

# --------------------------------------------------------------------------------------------------
# idea for every db_service in aws>>
# after elasticache is created, we require
#1. elasticache_Endpoint
#2. Security_Group (separate for elasticache)
#3. IAM permission to app , to access elasticache >> inside app_module

# elasticache_endpoint
resource "aws_ssm_parameter" "elasticache_endpoint" {
  name  = "${var.env}.elasticache.endpoint"
  type  = "String"
  value = aws_elasticache_cluster.redis.cache_nodes[0].address       # from output block (output.tf), as there is only one node in the cluster
}

# Security_Group for elasicache
resource "aws_security_group" "main" {
  name        = "elasticache-${var.env}-sg"
  description = "elasticache-${var.env}-sg"
  vpc_id      = var.vpc_id


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ELASTICACHE"
    from_port        = var.port           # inside ELASTICACHE we are opening port 6379
    to_port          = var.port           # inside ELASTICACHE we are opening port 6379
    protocol         = "tcp"
    cidr_blocks      = var.cidr_block     # here we have to specify which (app)subnet should access the elasticache (not in terms of subnet_id, but in terms of cidr_block)
  }

  tags = {
    merge (var.tags, Name = "elasticache-${var.env}-security-group")
}
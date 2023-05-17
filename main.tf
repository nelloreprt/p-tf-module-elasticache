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
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.env}-elasticache-subnet-group-main"
  subnet_ids = var.subnet_ids
}


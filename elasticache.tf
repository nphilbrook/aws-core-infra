resource "aws_elasticache_serverless_cache" "test_dynamic" {
  provider = aws.usw2
  engine   = "redis"
  name     = "test-dynamic"
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  daily_snapshot_time      = "09:00"
  description              = "Test Server"
  major_engine_version     = "7"
  snapshot_retention_limit = 1
  # security_group_ids       = [aws_security_group.test.id]
  subnet_ids = aws_subnet.test[*].id
}

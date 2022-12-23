resource "aws_s3_bucket" "world_files" {
  bucket = "minecraft-backup-crafty-world"
}

resource "aws_s3_object" "backup_file" {
  bucket = aws_s3_bucket.world_files.bucket
  key    = "serverfiles/backup.sh"
  source = "${path.module}/backup.sh"
  etag   = filemd5("${path.module}/backup.sh")
}

resource "aws_s3_object" "minecraft_files" {
  for_each = toset([
    "ops.json",
    "server.properties",
    "whitelist.json",
    "minecraft.service",
    "server-icon.png",
    "user_jvm_args.txt"
  ])
  bucket = aws_s3_bucket.world_files.bucket
  key    = "minecraft/${each.key}"
  source = "${path.module}/minecraft/${each.key}"
  etag   = filemd5("${path.module}/minecraft/${each.key}")
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.world_files.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.world_files.bucket

  rule {
    id = "backups"

    expiration {
      days = 30
    }

    filter {
      and {
        prefix = "backups/"

        tags = {
          rule      = "backups"
          autoclean = "true"
        }
      }
    }

    status = "Enabled"
  }
}

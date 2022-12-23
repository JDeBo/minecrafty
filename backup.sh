#!/bin/sh
####################################
#
# Backup minecraft world to a
# specified folder.
#
####################################

# What to backup.  Name of minecraft folder in /opt/minecraft
backup_files="vault"

# S3 Bucket for backup
dest_bucket="minecraft-backup-crafty-world"

# Create backup archive filename.
day=$(date +%A)
archive_file="backups/$day-$backup_files.tar.gz"

# Backup the files using tar.
/bin/tar zcvf /opt/minecraft/$archive_file /opt/minecraft/$backup_files
/usr/local/bin/aws s3 bin/cp /opt/minecraft/$archive_file s3://$dest_bucket/backups/

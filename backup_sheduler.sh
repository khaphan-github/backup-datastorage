#!/bin/bash
# Backup scheduler script 00:00: 0 0 * * * ./backup_sheduler.sh
# Backup scheduler script 00:00: * * * * * ./backup_sheduler.sh
# This script creates a backup of the MySQL database using Percona XtraBackup
# and stores it in a Docker volume
# Set variables
BACKUP_VOLUME="backupvol_version_1"
MYSQL_CONTAINER="mysql_db"

# Create backup volume if it doesn't exist
docker volume inspect $BACKUP_VOLUME >/dev/null 2>&1 || docker volume create $BACKUP_VOLUME
# Run backup with root user
docker rm pxb >/dev/null 2>&1
docker run --name pxb --volumes-from $MYSQL_CONTAINER -v $BACKUP_VOLUME:/backup_$(date +%d%m)$(date +%d%m%Y) --network cluster_a_host_network -it --user root percona/percona-xtrabackup:8.0.34 /bin/bash -c "xtrabackup --backup --host=$MYSQL_CONTAINER --datadir=/var/lib/mysql/ --target-dir=/backup_$(date +%d%m)$(date +%d%m%Y) --user=root --password=rootpassword; xtrabackup --prepare --target-dir=/backup_$(date +%d%m)$(date +%d%m%Y)"
# Note: Replace 'rootpassword' with the actual root password of your MySQL database
# End of script
echo "Backup completed and stored in volume: $BACKUP_VOLUME"
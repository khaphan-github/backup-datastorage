# Backup datastore
## Networking & volumne prepare.
```bash
docker network create cluster_a_host_network
docker volume create backupvol_ver_29092025
docker volume create mysql_datastorage
docker volume inspect mysql_datastorage
```

## Run backup with root user
```bash
docker rm pxb
docker run --name pxb --volumes-from mysql_db -v backupvol_ver_29092025:/backup_1010_29092025 --network cluster_a_host_network -it --user root percona/percona-xtrabackup:8.0.34 /bin/bash -c "xtrabackup --backup --host=mysql_db --datadir=/var/lib/mysql/ --target-dir=/backup_1010_29092025 --user=root --password=rootpassword; xtrabackup --prepare --target-dir=/backup_1010_29092025"
```

## Check backupstorte
```bash
sudo ls -la /mnt/dae4cf6d-35d6-4a5e-8ca3-b5ad6ef52795/docker_vl/volumes/backupvol_ver_29092025/_data
sudo cat /mnt/dae4cf6d-35d6-4a5e-8ca3-b5ad6ef52795/docker_vl/volumes/backupvol_ver_29092025/_data/xtrabackup_info
sudo cat /mnt/dae4cf6d-35d6-4a5e-8ca3-b5ad6ef52795/docker_vl/volumes/backupvol_ver_29092025/_data/xtrabackup_binlog_info
docker volume inspect backupvol_ver_29092025
```
Optinal compress file
sudo tar -czf /mnt/dae4cf6d-35d6-4a5e-8ca3-b5ad6ef52795/docker_vl/volumes/backupvol_ver_29092025.tar.gz -C /mnt/dae4cf6d-35d6-4a5e-8ca3-b5ad6ef52795/docker_vl/volumes backupvol_ver_29092025
sudo cp /mnt/dae4cf6d-35d6-4a5e-8ca3-b5ad6ef52795/docker_vl/volumes/backupvol_ver_29092025.tar.gz $(pwd)

## Remove & copy back (restore) and Change Owner
```bash
docker run --volumes-from mysql_db -v backupvol_ver_29092025:/backupvol_ver_29092025 -it --rm --user root percona/percona-xtrabackup:8.0.34 /bin/bash -c "rm -rf /var/lib/mysql/* && xtrabackup --copy-back --datadir=/var/lib/mysql/ --target-dir=/backupvol_ver_29092025 && chown -R mysql:mysql /var/lib/mysql/"
```

## Plan:
- Create initalal data
- Create backup
- Addtional more data
- Stop service db
- Restore previous backup
- Start service db
=> Expected data must be restore at version backup.

### Create data
```sql
CREATE TABLE account_version1 (  
  id int NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT 'Primary Key',
  username VARCHAR(255) NOT NULL COMMENT 'Username',
  password VARCHAR(255) NOT NULL COMMENT 'Password',
  avatar VARCHAR(255) COMMENT 'Avatar URL',
  email VARCHAR(255) NOT NULL COMMENT 'Email Address',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Create Time',
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
  status TINYINT DEFAULT 1 COMMENT 'Status (1=active, 0=inactive)'
) ENGINE=MyISAM COMMENT='User table';

-- Insert 10 sample records into account_version1 table
INSERT INTO account_version1 (username, password, avatar, email, status) VALUES
('john_doe', 'hashed_password_1', 'https://example.com/avatars/john.jpg', 'john.doe@example.com', 1),
('jane_smith', 'hashed_password_2', 'https://example.com/avatars/jane.jpg', 'jane.smith@example.com', 1),
('mike_wilson', 'hashed_password_3', 'https://example.com/avatars/mike.jpg', 'mike.wilson@example.com', 1),
('sarah_johnson', 'hashed_password_4', 'https://example.com/avatars/sarah.jpg', 'sarah.johnson@example.com', 0),
('david_brown', 'hashed_password_5', 'https://example.com/avatars/david.jpg', 'david.brown@example.com', 1),
('emily_davis', 'hashed_password_6', 'https://example.com/avatars/emily.jpg', 'emily.davis@example.com', 1),
('chris_miller', 'hashed_password_7', 'https://example.com/avatars/chris.jpg', 'chris.miller@example.com', 1),
('lisa_taylor', 'hashed_password_8', 'https://example.com/avatars/lisa.jpg', 'lisa.taylor@example.com', 0),
('robert_anderson', 'hashed_password_9', 'https://example.com/avatars/robert.jpg', 'robert.anderson@example.com', 1),
('amanda_thomas', 'hashed_password_10', 'https://example.com/avatars/amanda.jpg', 'amanda.thomas@example.com', 1);
```


## TODO:
- [] Compress
- [] Encrypt 
- [] Push to cloud or system NF S
#!/bin/sh
BACKUP_DATE=`date "+%Y%m%d%H%M%S"`

cd "${HOME}/s3-backup-tool"
find . -name "*.gz" -type f -mtime +1 -print0 | xargs -0 rm -f
tar --exclude s3-backup-tool -zcvf "${S3_BACKUP_ID}.${BACKUP_DATE}.tar.gz" "${S3_BACKUP_PATH}" 
/usr/bin/mysqldump --all-databases --single-transaction --events | gzip -c > "${S3_BACKUP_ID}.${BACKUP_DATE}.sql.gz"
#/usr/bin/mysqldump --all-databases --single-transaction --events --master-data=2 --flush-logs | gzip -c > "${HOSTNAME}.${BACKUP_DATE}.sql.gz" # mysqlのバイナリログが有効な場合
aws s3 cp . "s3://s3-backup-tool/${S3_BACKUP_ID}" --recursive --exclude "*" --include "${S3_BACKUP_ID}.${BACKUP_DATE}.*.gz"

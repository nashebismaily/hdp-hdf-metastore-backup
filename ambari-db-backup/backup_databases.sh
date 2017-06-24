#!/bin/bash

##
# This script will backup the Ambari, Ranger, Ranger KMS, Oozie, Hive, Druid, Superset datatabses in Postgres.
# This script will also backup SAM and Schema Registry databases in MySQL.
#
# This script should run on the server running the databases.
# This script assumes this server is the same as the ambari server.
#
# Author: Nasheb Ismaily
#
##

usage() { echo "Usage: $0 [-r <# days to retain backup>]" 1>&2; exit 1; }

while getopts ":r:" opt; do
    case "${opt}" in
        r)
            RETENTION=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${RETENTION}" ]; then
    usage
fi

#Date in format YYYYmmdd-HHMMSS
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

POSTGRES_PASSWORDS_FILE=~/.pgpass
MYSQL_PASSWORDS_FILE=~/.my.cnf
DB_TMP_BACKUP_LOCATION=/grid/1/hdp_database_backups/tmp
DB_BACKUP_LOCATION=/grid/1/hdp_database_backups
DB_CONF_FILE=db.conf

source db.conf

# Create Passowrd File For Postgres (Only do this once)
if [ ! -f $POSTGRES_PASSWORDS_FILE ]; then
  touch $POSTGRES_PASSWORDS_FILE
  chmod 0600 $POSTGRES_PASSWORDS_FILE

  echo "$postgres_host:$postgres_port:$ambari_db:$ambari_user:$ambari_password" >> $POSTGRES_PASSWORDS_FILE
  echo "$postgres_host:$postgres_port:$hive_db:$hive_user:$hive_password" >> $POSTGRES_PASSWORDS_FILE
  echo "$postgres_host:$postgres_port:$oozie_db:$oozie_user:$oozie_password" >> $POSTGRES_PASSWORDS_FILE
  echo "$postgres_host:$postgres_port:$ranger_db:$ranger_user:$ranger_password" >> $POSTGRES_PASSWORDS_FILE
  echo "$postgres_host:$postgres_port:$rangerkms_db:$rangerkms_user:$rangerkms_password" >> $POSTGRES_PASSWORDS_FILE
  echo "$postgres_host:$postgres_port:$druid_db:$druid_user:$druid_password" >> $POSTGRES_PASSWORDS_FILE
  echo "$postgres_host:$postgres_port:$superset_db:$superset_user:$superset_password" >> $POSTGRES_PASSWORDS_FILE
fi

# Create Password File for MySQL (Only do this once)

if [ ! -f $MYSQL_PASSWORDS_FILE ]; then
  touch $MYSQL_PASSWORDS_FILE
  chmod 0600 $MYSQL_PASSWORDS_FILE

  echo "[mysqldump]" >> $MYSQL_PASSWORDS_FILE
  echo "user=$mysql_user" >> $MYSQL_PASSWORDS_FILE
  echo "password=$mysql_password" >> $MYSQL_PASSWORDS_FILE
fi


# Create Backup Database
mkdir -p $DB_TMP_BACKUP_LOCATION

# Stop Ambari
ambari-server stop

#Backup Ambari
pg_dump -w -U $ambari_user $ambari_db > $DB_TMP_BACKUP_LOCATION/$ambari_backup_file

# Start Ambari
ambari-server start

# Backup Other HDP Postgress Databases

pg_dump -w -U $hive_user $hive_db > $DB_TMP_BACKUP_LOCATION/$hive_backup_file
pg_dump -w -U $oozie_user $oozie_db > $DB_TMP_BACKUP_LOCATION/$oozie_backup_file
pg_dump -w -U $ranger_user $ranger_db > $DB_TMP_BACKUP_LOCATION/$ranger_backup_file
pg_dump -w -U $rangerkms_user $rangerkms_db > $DB_TMP_BACKUP_LOCATION/$rangerkms_backup_file
pg_dump -w -U $druid_user $druid_db > $DB_TMP_BACKUP_LOCATION/$druid_backup_file
pg_dump -w -U $superset_user $superset_db > $DB_TMP_BACKUP_LOCATION/$superset_backup_file

# Backup MySQL Databases

mysqldump --databases $registry_db  > $DB_TMP_BACKUP_LOCATION/$registry_backup_file
mysqldump --databases $streamline_db  > $DB_TMP_BACKUP_LOCATION/$streamline_backup_file

#Compress Directory
current_dir=$(pwd)
compressed_backup_file=hdp_mestastores_backup_$TIMESTAMP.tar.gz

cd $DB_TMP_BACKUP_LOCATION && sudo tar czf $compressed_backup_file *
mv $compressed_backup_file $DB_BACKUP_LOCATION

#Remove temporary data
rm -rf $DB_TMP_BACKUP_LOCATION

cd $current_dir

# Remove Files older than 5 days
find $DB_BACKUP_LOCATION -mindepth 1 -mtime +${RETENTION} -delete

#Exit cleanly
exit 0


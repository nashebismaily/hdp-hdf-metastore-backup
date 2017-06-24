# Hortonworks Data Platform/Flow Metastore Backup

The scripts will backup the embedded Ambari database: Postgres and MySQL for HDF's Schema Registry and Streaming Analytics Manager.  
Currently the Schema Registry and SAM only support MySQL, this is why multiple databases are used.  

## configure_postgres.sh  

This script will configure the pg_hba.conf in postgres to allow the db users to connect to it for backup  
This script can be run as follows: ./configure_postgres.sh

#backup_databases.sh  

This script will perform the backup of the HDP metastores in Postgres: Ambari, Ranger, RangerKMS, Hive, Oozie, Druid, and Superset.  
It will also backup the HDF metastores in MySQL: registry, and streamline.  
The backups will be compressed into a tar file.  
The script requires a retention parameter. This will dictate how long the backups will remain before auto deletion.  
This script can be run as follows: ./backup_databases.sh -r <# retention days>  

## db.conf

This configuration file contains the user names, database names, and passwords for the HDP/HDF metastores.
The file also contains connection information for Postgres and MySQL.

## Author
Nasheb Ismaily




#!/bin/bash

##
#
# This script will configure the connection properties for the users and databases in Postgres.
# This script needs to run ONLY once.
# This script must be run before the backup script is run for the first time.
#
# Author: Nasheb Ismaily
#
##

source db.conf

POSTGRES_HBA_FILE=/var/lib/pgsql/data/pg_hba.conf

#Udpate postgres configuration
echo "local  all  $ambari_user,$hive_user,$oozie_user,$ranger_user,$rangerkms_user,$druid_user,$superset_user  trust" >> $POSTGRES_HBA_FILE
echo "host   all  $ambari_user,$hive_user,$oozie_user,$ranger_user,$rangerkms_user,$druid_user,$superset_user  0.0.0.0/0  trust" >> $POSTGRES_HBA_FILE
echo "host   all  $ambari_user,$hive_user,$oozie_user,$ranger_user,$rangerkms_user,$druid_user,$superset_user  ::/0  trust" >> $POSTGRES_HBA_FILE

#Restart postgres
service postgresql restart

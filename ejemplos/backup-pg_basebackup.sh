#!/bin/bash
# Store backup path
BACKUP="/mnt/backups_elearning/backup_postgresql/basebackup"

PGHOST="dbpostgres2.lan.cesga.es"
PGUSER="replication"
# to avoid asking for password create de variable PGPASSFILE
#export PGPASSFILE="/root/.pgpass"

# Paths for binary files
TAR="/bin/tar"
PG_BASEBACKUP="/usr/bin/pg_basebackup"
LOGGER="/usr/bin/logger"

cd $BACKUP
case "$1" in
      full)
        # Full Backup of all Databases
        # Log backup end time in /var/log/messages
        # Create backup dir
        REMOTEBACKUP="$(date +'%A')_$(date +'%F')"
        # Remove this-day-last-week backup and create new backup dir
        rm -rf ${BACKUP}/$(date +'%A')_*;mkdir ${REMOTEBACKUP}
        $LOGGER "$0: *** ${BBDD} Full backup started @ $(date) ***"
        $PG_BASEBACKUP -h ${PGHOST} -U ${PGUSER} -D ./${REMOTEBACKUP} -P -U replication --wal-method=stream
        $LOGGER "$0: *** ${BBDD} Full backup finished @ $(date) ***"
      ;;
      incremental)
        echo "=nwork"
      ;;
      *)
        echo "Usage: $0 [full|incremental]"
      ;;
esac

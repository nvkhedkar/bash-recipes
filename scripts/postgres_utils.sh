#!/bin/bash

#!/bin/bash

AIRFLOW_DB_BKP_FILE=airflow_pgdb.bak
AIRFLOW_DB_BKP_DIR=~/db_bkp
PG_RESTORE_ERR_LOG=/tmp/pg_restore_err.log
PG_DUMP_ERR_LOG=/tmp/pg_dump_err.log
PGPASS=
DBNAME=
DBUSER=
DBHOST=0.0.0.0
DBPORT=5432

# pg_restore -v --no-owner --host=0.0.0.0 --port=5432 --username=airflow --dbname=airflow manageddatabase.dump

LOG_FILE=$AIRFLOW_DB_BKP_DIR/restore_db.log
#. /myprojid/pymyproj/scripts/common.sh --source_only

log()
{
  MESSAGE=$1
  if [ $# -eq 1 ]; then
	  echo "$MESSAGE"
	fi
  echo "$MESSAGE" >> $LOG_FILE
#    echo "`date` :: $MESSAGE" >> $LOG_FILE
}

show_title()
{
log ""
log ""
log "========================================================================="
log "$1"
log "-------------------------------------------------------------------------"
}


#==============================================================================
# Run command functions
#==============================================================================
run_cmd()
{
  CMD=$1
  log " "
  log "---------------------------------"
  log "Running $CMD"
  RUNCMDOUT=$($CMD 2>&1)
  log "$RUNCMDOUT"
}


create_pgdb_user_db()
{
  lpgusr=$1
  lpgpass=$2
  ldbname=$3
  log "Creating user $lpgusr"
  sudo -u postgres bash -c "psql -c \"CREATE USER $lpgusr WITH PASSWORD '$lpgpass';\""
  sudo -u postgres bash -c "psql -c \"ALTER USER $lpgusr WITH CREATEDB;\""
  log "Creating database $ldbname"
  sudo -u postgres bash -c "psql -c \"CREATE DATABASE $ldbname;\""
  log "Grant permissions to $lpgusr"
  sudo -u postgres bash -c "psql -c \"GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $lpgusr;\""
}


reset_database()
{
  # Stop services using the db first
  
  # End
  log "Drop database"
  sudo -u postgres bash -c "psql -c \"DROP DATABASE $DBNAME;\""
  create_pgdb_user_db "$DBUSER" "$PGPASS" "$DBNAME"
}

restore_database_pg()
{
  sudo -u postgres bash -c "psql -c \"ALTER USER $DBUSER WITH SUPERUSER;\""
  export PGPASSWORD="$PGPASS"
  show_title "Running airflow db restore command"
  # sudo -u postgres bash -c "pg_restore -v -Fc --no-owner -h 0.0.0.0 -p 5432 -U airflow -d airflow afdbc.bak"
  # pg_restore -v -Fc --no-owner -h 0.0.0.0 -p 5432 -U airflow -d airflow afdbc.bak
  pg_restore -v -Fc --no-owner -h $DBHOST -p $DBPORT -U $DBUSER -d $DBNAME $AIRFLOW_DB_BKP 2>"$PG_RESTORE_ERR_LOG"
  run_cmd "cat $PG_RESTORE_ERR_LOG"
  log "$RUNCMDOUT"
  sudo -u postgres bash -c "psql -c \"ALTER USER $DBUSER WITH NOSUPERUSER;\""
  sudo -u postgres bash -c "psql -c \"\du\""

}


backup_pgdb()
{
  if [ -d "$AIRFLOW_DB_BKP_DIR" ]; then
    echo "found logs dir"
  else
    cd /myproj
    run_cmd "sudo mkdir -p $AIRFLOW_DB_BKP_DIR"
    run_cmd "sudo chown -R ccsteam:ccsteam $AIRFLOW_DB_BKP_DIR"
  fi

  if [[ -f "$AIRFLOW_DB_BKP" ]]; then
    run_cmd "sudo mv $AIRFLOW_DB_BKP $AIRFLOW_DB_BKP_TMP"
  fi

  if [[ -f "$PG_DUMP_ERR_LOG" ]]; then
    run_cmd "sudo rm $PG_DUMP_ERR_LOG"
  fi

  export PGPASSWORD="$PGPASS"
  show_title "Running airflow db backup command"
  # pg_dump -h 0.0.0.0 -p 5432 -U airflow -d airflow > afdb.bak
  # pg_dump -h 0.0.0.0 -p 5432 -U airflow -d airflow -Fc > afdbc.bak
  pg_dump -h $DBHOST -p $DBPORT -U $DBUSER -d $DBNAME -Fc > $AIRFLOW_DB_BKP 2>"$PG_DUMP_ERR_LOG"

  actualsize=$(du -k "$AIRFLOW_DB_BKP" | cut -f 1)
  log "File size: $actualsize"
  run_cmd "cat $PG_DUMP_ERR_LOG"
  if [[ $RUNCMDOUT == "" ]]; then
    run_cmd "sudo rm -rf $AIRFLOW_DB_BKP_TMP"
    run_cmd "ls -lh $AIRFLOW_DB_BKP"
    log "script was successfull"
  else
    run_cmd "sudo mv $AIRFLOW_DB_BKP_TMP $AIRFLOW_DB_BKP"
    log "Found error while running"
  fi
}


#============================================================================
ACTION=
# sudo -u postgres bash -c "restore_db --host=10.192.41.168 --user=airflow --db-name=airflow --pass=airflow --in=191210afdbc.bak"
# afpgdb --host=10.192.41.168 --user=airflow --db-name=airflow --pass=airflow --bkpfile=191210afdbc.bak --action=restore
# afpgdb --host=10.192.41.168 --user=airflow --db-name=airflow --pass=airflow --bkpfile=191210afdbc.bak --action=backup
for i in $@
do
  if [[ $i = "--action="* ]]; then
    ACTION=$(sed -e 's/^--action=//' <<< $i)
  fi
  if [[ $i = "--host="* ]]; then
    DBHOST=$(sed -e 's/^--host=//' <<< $i)
  fi
  if [[ $i = "--port="* ]]; then
    DBPORT=$(sed -e 's/^--port=//' <<< $i)
  fi
  if [[ $i = "--user="* ]]; then
    DBUSER=$(sed -e 's/^--user=//' <<< $i)
  fi
  if [[ $i = "--db-name="* ]]; then
    DBNAME=$(sed -e 's/^--db-name=//' <<< $i)
  fi
  if [[ $i = "--pass="* ]]; then
    PGPASS=$(sed -e 's/^--pass=//' <<< $i)
  fi
  if [[ $i = "--bkpfile="* ]]; then
    AIRFLOW_DB_BKP_FILE=$(sed -e 's/^--bkpfile=//' <<< $i)
  fi
  if [[ $i = "--bkpdir="* ]]; then
    AIRFLOW_DB_BKP_DIR=$(sed -e 's/^--bkpdir=//' <<< $i)
  fi
done
AIRFLOW_DB_BKP="$AIRFLOW_DB_BKP_DIR/$AIRFLOW_DB_BKP_FILE"
AIRFLOW_DB_BKP_TMP="$AIRFLOW_DB_BKP.tmp"


if [[ "$ACTION" = "restore" ]]; then
  reset_database
  restore_database_pg
fi

if [[ "$ACTION" = "backup" ]]; then
  backup_pgdb
fi

exit 0

#echo "airflow\n" | (pg_dump -U airflow -h 0.0.0.0 -W -d airflow > ~/$1)

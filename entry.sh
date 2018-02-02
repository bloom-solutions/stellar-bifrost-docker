#!/bin/bash

set -e

main () {
  export BIFROST_DATA_DIR=/opt/bifrost/data
  export BIFROST_CONFIG_DIR=/opt/bifrost/config

  templater /opt/templates/pg.template > /root/.pgpass
  chmod 600 /root/.pgpass

  psql -h $BIFROST_DB_HOST -U $POSTGRES_USER -c 'select 1' $BIFROST_DB_NAME
  while ! psql -h $BIFROST_DB_HOST -U $POSTGRES_USER -c 'select 1' $BIFROST_DB_NAME &> /dev/null
  do
    echo "Waiting for bifrostdb to be available..."
    sleep 1
  done

  echo "Initializing Bifrost DB..."
  init_bifrost_db
  start_bifrost
}

init_bifrost_db () {
  if [ -f $BIFROST_DATA_DIR/.bifrostdb-initialized ]
  then
    echo "Bifrost DB: already initialized"
    return 0
  fi

  echo "Bifrost DB: Initializing"
  DB_URL=$BIFROST_DB_DSN DB_DUMP_FILE=/go/src/github.com/stellar/go/services/bifrost/database/migrations/01_init.sql /go/bin/initbifrost

  touch $BIFROST_DATA_DIR/.bifrostdb-initialized
}

function start_bifrost() {
  echo "Starting bifrost..."
  bifrost server -c $BIFORST_CONFIG_DIR/bifrost.cfg
}

main

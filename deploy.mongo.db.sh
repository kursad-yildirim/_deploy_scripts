#!/bin/bash
if [ $# -eq 2 ]
  then
    DB_SERVER=$3
    DB_PORT=$4
  else
    echo 'Too few parameters.'
    echo 'usage: deploy.mongo.db.sh db_server db_port'
    exit
fi
CONTAINER='/usr/bin/podman'
WORKDIR='/home/workspace'
APPDIR=$WORKDIR/data/mongodb/$DB_NAME


$CONTAINER run --name db-mongodb-$DB_NAME -d mongo:bionic
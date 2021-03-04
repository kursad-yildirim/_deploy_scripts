#!/bin/bash
if [ $# -eq 4 ]
  then
    API_PORT=$1
    DB_SERVER=$2
    DB_NAME=$3
    DB_REQUIRED=$4
    TAG=$5
  else
    echo 'Too few parameters.'
    echo 'usage: deploy.sh api_port db_server db_name db_required api-version'
    exit
fi
DB_NAME='coinnow'
MODULE='get-price'
CONTAINER='/usr/bin/podman'
WORKDIR='/home/workspace'
APPDIR=$WORKDIR/crud/$DB_NAME
TEMPLATEDIR=$WORKDIR/crud/main
mkdir -p $APPDIR
cp -R $TEMPLATEDIR/* $APPDIR/
cat > $APPDIR/code.dev/Dockerfile << EOLDOCKERFILE
FROM node:lts-alpine3.13

WORKDIR /usr/src/app

ENV API_PORT=$API_PORT
ENV DB_SERVER=$DB_SERVER
ENV DB_NAME=$DB_NAME
ENV DB_REQUIRED=$DB_REQUIRED

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE $API_PORT

CMD [ "npm", "start" ]
EOLDOCKERFILE

$CONTAINER build $APPDIR/code.dev -t db-crud-$DB_NAME:$TAG >/dev/null 2>&1

$CONTAINER ps -a | grep db-crud-$DB_NAME | awk '{print $1}'| xargs podman stop
$CONTAINER ps -a | grep db-crud-$DB_NAME | awk '{print $1}'| xargs podman rm

$CONTAINER run --name db-crud-$DB_NAME-$TAG -d db-crud-$DB_NAME:$TAG
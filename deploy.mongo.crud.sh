#!/bin/bash
if [ $# -eq 6 ]
  then
    APP_NAME=$1
    API_PORT=$2
    DB_SERVER=$3
    DB_PORT=$4
    DB_NAME=$5
    DB_REQUIRED=$6
  else
    echo 'Too few parameters.'
    echo 'USAGE: deploy.mongo.crud.sh app_name api_port db_server db_port db_name db_required'
    exit
fi
TAG=$(git log | grep 8Mega | awk -F "_" '{print $4}')
CONTAINER='/usr/bin/podman'
WORKDIR='/home/workspace'
APPDIR=$WORKDIR/node.js/crud/$DB_NAME
TEMPLATEDIR=$WORKDIR/node.js/crud/nodejs-crud-mongodb
DB_IP=$(podman ps | grep "db-mongodb-$DB_NAME" | awk '{print $1}'| xargs podman inspect| grep IPAddress|awk '{print $2}'| awk -F "\"" '{print $2}')

mkdir -p $APPDIR
cp -R $TEMPLATEDIR/* $APPDIR/

cat > $APPDIR/code.dev/Dockerfile << EOLDOCKERFILE
FROM node:lts-alpine3.13

WORKDIR /usr/src/app

ENV APP_NAME=$APP_NAME
ENV API_PORT=$API_PORT
ENV DB_SERVER=$DB_SERVER
ENV DB_PORT=$DB_PORT
ENV DB_IP=$DB_IP
ENV DB_NAME=$DB_NAME
ENV DB_REQUIRED=$DB_REQUIRED

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE $API_PORT

CMD [ "npm", "start" ]
EOLDOCKERFILE

$CONTAINER build $APPDIR/code.dev -t db-crud-$APP_NAME:$TAG >/dev/null 2>&1

$CONTAINER ps -a | grep db-crud-$APP_NAME | awk '{print $1}'| xargs podman stop
$CONTAINER ps -a | grep db-crud-$APP_NAME | awk '{print $1}'| xargs podman rm

$CONTAINER run --name db-crud-$APP_NAME-$TAG -d db-crud-$DB_NAME:$TAG
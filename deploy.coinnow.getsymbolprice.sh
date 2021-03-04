#!/bin/bash
if [ $# -eq 3 ]
  then
    APP_NAME=$1
    APP_PORT=$2
    DB_NAME=$5
  else
    echo 'Too few parameters.'
    echo 'USAGE: deploy.coinnow.getsymbolprice.sh app_name app_port db_name'
    exit
fi
TAG=$(git log | grep 8Mega | awk -F "_" '{print $4}')
CONTAINER='/usr/bin/podman'
WORKDIR='/home/workspace'
APPDIR=$WORKDIR/node.js/coinnow/$APP_NAME
DB_REST_IP=$(podman ps | grep "db-crud-$APP_NAME" | awk '{print $1}'| xargs podman inspect| grep IPAddress|awk '{print $2}'| awk -F "\"" '{print $2}')
DB_REST_PORT=$(podman ps | grep "db-crud-$APP_NAME" | awk '{print $1}'| xargs podman inspect| grep API_PORT|awk -F "=" '{print $2}'|awk -F "\"" '{print $1}'

cat > $APPDIR/code.dev/Dockerfile << EOLDOCKERFILE
FROM node:lts-alpine3.13

WORKDIR /usr/src/app

ENV APP_NAME=$APP_NAME
ENV APP_PORT=$APP_PORT
ENV DB_REST_URL=http://$DB_REST_IP:$DB_REST_PORT/crud/$APP_NAME

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE $APP_PORT

CMD [ "npm", "start" ]
EOLDOCKERFILE

$CONTAINER build $APPDIR/code.dev -t coinnow-$APP_NAME:$TAG >/dev/null 2>&1

$CONTAINER ps -a | grep coinnow-$APP_NAME | awk '{print $1}'| xargs podman stop
$CONTAINER ps -a | grep coinnow-$APP_NAME | awk '{print $1}'| xargs podman rm

$CONTAINER run --name coinnow-$APP_NAME-$TAG -d db-crud-$APP_NAME:$TAG
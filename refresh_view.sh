#!/bin/sh

DB_SERVER=${DB_SERVER:=couchdb}
DB_NAME=${DB_NAME:=cron}
URL="http://${DB_SERVER}:5984/${DB_NAME}/_design/cronview"

REV=`wget -O - -q ${URL} | sed "s/.*rev//g" | awk -F\" '{ print $3}'`

curl -X DELETE "${URL}?rev=${REV}"

curl -s -X PUT -H "text/plain;charset=utf-8" -d @couchdb_view $URL
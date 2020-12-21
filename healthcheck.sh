#!/bin/bash

FILE=/config/config.ini

until test -f $FILE; do sleep 1; done

API=$(cat /config/config.ini | grep 'apikey =' | awk -F '= ' '{print $2}')
curl -f "http://localhost:6767/sabnzbd/api?mode=queue&output=json&apikey=$API" || exit 1

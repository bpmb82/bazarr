#!/bin/bash

FILE=/config/config.ini

until test -f $FILE; do sleep 1; done

API=$(cat /config/config.ini | grep 'apikey =' | egrep -v 'disable|rating' | awk -F '= ' '{print $2}')
curl -f "http://localhost:8080/sabnzbd/api?mode=queue&output=json&apikey=$API" || exit 1
#!/bin/bash

curl localhost:6767/api && curl api.ipify.org || exit 1

#!/bin/bash
run-parts /docker-entrypoint-initweb.d
echo 'start'
tail -f /dev/null
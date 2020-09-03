#!/bin/bash
set -e
for file in /docker-entrypoint-initweb.d/*
do
  cmd [option] "$file" >> /docker-entrypoint-initweb.d/results.out
done

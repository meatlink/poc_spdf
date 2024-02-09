#!/bin/sh
set -eu
cd "$( dirname "$0" )"

cd docker
docker build -t spdk:v1 .

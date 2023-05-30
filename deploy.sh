#!/bin/bash

REGISTRY="sgtcoder"
PROJECT_NAME="apache-base"

#./deploy.sh --no-cache
docker build "$1" -t $REGISTRY/$PROJECT_NAME . || exit 1
docker push $REGISTRY/$PROJECT_NAME

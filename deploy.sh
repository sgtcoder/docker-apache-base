#!/bin/bash

REGISTRY="sgtcoder"
PROJECT_NAME="apache-base"

docker build -t $REGISTRY/$PROJECT_NAME .
docker push $REGISTRY/$PROJECT_NAME

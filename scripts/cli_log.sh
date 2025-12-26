#!/usr/bin/env bash

## Color Set ##
color_reset='\033[0m'
color_red='\033[1;31m'
color_green='\033[1;32m'
color_yellow='\033[1;33m'

## Get Inputs ##
status=$1
message=$2
type=$3

if [ -z $status ]; then
    while read IN; do echo [$(date -u +"%Y-%m-%d %T")] $(echo "$IN" | sed "s/^[^ ]*/\U&\E/"); done
else
    if [ "$status" == "SUCCESS" ]; then
        color=$color_green
    elif [ "$status" == "ERROR" ]; then
        color=$color_red
    elif [ "$status" == "INFO" ]; then
        color=$color_yellow
    else
        color=$color_reset
    fi

    ## Header ##
    header=$(echo -e "[$(date -u +"%Y-%m-%d %T")] $status: $message")

    if [ "$type" == "header" ]; then
        echo ""
    fi

    if [ "$type" == "border" ]; then
        echo ""
        echo $(seq 0 ${#header} | xargs printf '=%.0s')
    fi

    echo -e "[$(date -u +"%Y-%m-%d %T")] $color$status:$color_reset $message"

    if [ "$type" == "header" ]; then
        echo $(seq 0 ${#header} | xargs printf '=%.0s')
    fi

    if [ "$type" == "border" ]; then
        echo $(seq 0 ${#header} | xargs printf '=%.0s')
        echo ""
    fi
fi

#!/usr/bin/env bash

curl -fsSL "$1" | gpg --dearmor | tee /etc/apt/keyrings/"$2".gpg >/dev/null
chown _apt /etc/apt/keyrings/*.gpg
chmod 644 /etc/apt/keyrings/*.gpg

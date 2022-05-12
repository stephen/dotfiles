#!/bin/bash

# run echoes and runs.
run() {
  echo "$@" && "$@"
}

echo Installing apps from homebrew...
run brew bundle -v --file=- <<-EOF
  cask "plex-media-server"
EOF


WYZE_PASSWORD=

# -n is no-clobber
cp -n ./configs/.env.sample ~/.env
read -p "Populate ~/.env with secrets. Press any key to begin..."
vim ~/.env

# pi-hole
set -a
source ~/.env && export SERVER_IP=$(ipconfig getifaddr en0) && docker-compose -f ./configs/docker-compose.yml up -d
networksetup -setdnsservers Ethernet 127.0.0.1

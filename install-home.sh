#!/bin/bash

# run echoes and runs.
run() {
  echo "$@" && "$@"
}

echo Installing apps from homebrew...
run brew bundle -v --file=- <<-EOF
  cask "plex-media-server"
EOF

# --restart helps keep it alive
docker pull pihole/pihole
docker run -d --name pihole -e ServerIP=$(ipconfig getifaddr en0) -e WEBPASSWORD="password" -e DNS1=8.8.8.8 -p 80:80 -p 53:53/tcp -p 53:53/udp -p 443:443 --restart always pihole/pihole:latest
networksetup -setdnsservers Ethernet 127.0.0.1

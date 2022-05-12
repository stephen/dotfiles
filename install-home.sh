#!/bin/bash

# run echoes and runs.
run() {
  echo "$@" && "$@"
}

# run sudo pre-emptively for later steps
sudo echo "Installing for home server..."

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

# homebridge
sudo npm install -g --unsafe-perm homebridge homebridge-config-ui-x
sudo hb-service install

# ring needs ffmpeg with fdk-aac codec. i couldn't figure out why this doesn't work
# in the brewfile.
brew tap homebrew-ffmpeg/ffmpeg
brew install homebrew-ffmpeg/ffmpeg/ffmpeg --with-fdk-aac
npm i -g --unsafe-perm homebridge-ring
npm i -g --unsafe-perm homebridge-xiaomi-roborock-vacuum@latest

# setup ssh
open "x-apple.systempreferences:com.apple.preference.security"
read -p "Turn on full disk access for this terminal to enable ssh access. Press any key to continue..."
sudo systemsetup -setremotelogin on

# shell for ssh
run ln -fsv "$(greadlink -f ./configs/robbyrussell-remote.zsh-theme)" ~/.oh-my-zsh/themes/robbyrussell-remote.zsh-theme

echo "ZSH_THEME=\"robbyrussell-remote\"" >> ~/.zshrc

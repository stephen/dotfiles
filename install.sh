#!/bin/bash

# Set the working directory to where the file is.
cd "$(dirname "$0")" || return

case $(uname -s) in
Darwin) OS=darwin ;;
Linux) OS=linux ;;
*) echo "Unsupport OS $(uname -s)"; exit 1 ;;
esac

# run echoes and runs.
run() {
  echo "$@" && "$@"
}

git config --global user.email "stephen@stephenwan.com"
git config --global user.name "Stephen Wan"

case $OS in
darwin)
echo Setting up mac defaults...
# Pointer
defaults write -g com.apple.trackpad.scaling 0.875
defaults write -g com.apple.mouse.scaling -1

# Keyboard
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 1

# Dock
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool FALSE

# Keyboard
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 # Support tabbing between any controls.

# brew installation will also add basic xcode tools (git).
echo Checking if brew installed...
if ! which brew >/dev/null 2>&1; then
  echo Installing brew.
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

if [[ ! -f ~/.ssh/id_rsa ]]; then
	ssh-keygen -t rsa -b 4096 -C "stephen@stephenwan.com" -P "" -f ~/.ssh/id_rsa
fi

echo Installing apps from homebrew...
run brew update
run brew bundle -v --file=- <<-EOF
  tap "homebrew/cask-versions"
  cask "google-chrome-canary"

  tap "spotify/public"
  cask "spotify"

  brew "direnv"
  brew "git"
  brew "mosh"
  brew "watchman"
  brew "mas"
  brew "coreutils"
  brew "fasd"
  cask "visual-studio-code"
  cask "rectangle"
  cask "iterm2"
  cask "flux"
  cask "ngrok"
  cask "licecap"
EOF

echo Installing apps from Mac App Store...
run mas install 1451685025 # wireguard
run mas install 775737590 # ia writer
run mas install 425424353 # unarchiver
;;
linux)

run sudo apt-get update
run sudo apt-get install -y \
  mosh \
  zsh \
  tmux \
  fasd

esac


if [[ ! -d ~/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo Installing fzf...
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

echo Symlinking configurations into home...
case $OS in
darwin)
run ln -fsv "$(greadlink -f ./configs/com.knollsoft.Rectangle.plist)" ~/Library/Preferences/
run ln -fsv "$(greadlink -f .gitconfig)" ~
run ln -fsv "$(greadlink -f ./configs/.zshrc)" ~
run ln -fsv "$(greadlink -f ./bin)" ~

# Setup iterm2
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$HOME/git/dotfiles/configs/iterm2"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

;;
linux)

run ln -fsv "$(readlink -f .gitconfig)" ~
run ln -fsv "$(readlink -f ./bin)" ~

esac

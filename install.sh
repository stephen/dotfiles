#!/bin/bash

case $(uname -s) in
Darwin) OS=darwin ;;
Linux) OS=linux ;;
*) echo "Unsupport OS $(uname -s)"; exit 1 ;;
esac

git config --global user.email "stephen@stephenwan.com"
git config --global user.name "Stephen Wan"

if [[ ! -f ~/.ssh/id_rsa ]]; then
	ssh-keygen -t rsa -b 4096 -C "stephen@stephenwan.com" -P "" -f ~/.ssh/id_rsa
fi

# run echoes and runs.
run() {
  echo "$@" && GO111MODULE="$GO111MODULE" "$@"
}

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

# brew installation will also add basic xcode tools (git).
echo Checking if brew installed...
if ! which brew >/dev/null 2>&1; then
  echo Installing brew.
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

echo Installing apps from homebrew...
run brew update
run brew bundle -v --file=- <<-EOF
  brew "direnv"
  brew "git"
  brew "mosh"
  brew "watchman"
  brew "mas"
  cask "visual-studio-code"
  cask "rectangle"
  cask "iterm2"
  cask "flux"
EOF

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo Checking for fzf...
if ! which fzf ; then
  echo Installing fzf...
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi

echo Installing apps from Mac App Store...
run mas install 1451685025 # wireguard
run mas install 775737590 # ia writer
run mas install 425424353 # unarchiver

echo Symlinking configurations into home...
run ln -fsv ~/git/dotfiles/.gitconfig ~

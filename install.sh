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

if [[ ! -f ~/.ssh/id_rsa ]]; then
	ssh-keygen -t rsa -b 4096 -C "stephen@stephenwan.com" -P "" -f ~/.ssh/id_rsa
fi

case $OS in
darwin)
echo Setting up mac defaults...
# Pointer
sudo xcodebuild -license accept

defaults write -g com.apple.trackpad.scaling 0.875
defaults write -g com.apple.mouse.scaling -1

# Keyboard
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g NSWindowShouldDragOnGesture -bool true
defaults write -g InitialKeyRepeat -int 10
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
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/stephen/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

mkdir -p ~/bin/

echo Installing apps from homebrew...
run brew update
run brew bundle -v --file=- <<-EOF
  cask "unnaturalscrollwheels"

  tap "spotify/public"
  cask "spotify"

  cask "google-chrome"

  brew "lnav"
  brew "ghostty"
  brew "stripe/stripe-cli/stripe"
  brew "golang"
  brew "node"
  brew "direnv"
  brew "git"
  brew "mosh"
  brew "watchman"
  brew "jq"
  brew "mas"
  brew "coreutils"
  cask "docker"
  cask "lunar"
  cask "shifty"
  brew "ctop"
  cask "vlc"
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
run mas install 1475387142 # tailscale
;;
linux)

curl -fsSL https://pkgs.tailscale.com/stable/debian/buster.gpg | sudo apt-key add -
curl -fsSL https://pkgs.tailscale.com/stable/debian/buster.list | sudo tee /etc/apt/sources.list.d/tailscale.list

run sudo apt-get update
run sudo apt-get install -y \
  mosh \
  zsh \
  tmux \
  fasd \
  tailscale

esac


if [[ ! -d ~/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  chsh -s $(which zsh)
fi

echo Installing fzf...
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

echo Installing uv...
curl -LsSf https://astral.sh/uv/install.sh | sh

echo Symlinking configurations into home...

mkdir -p ~/.config/ghostty/
run ln -fsv "$(greadlink -f ./configs/.ghostty)" ~/.config/ghostty/config

case $OS in
darwin)

run ln -fsv "$(greadlink -f ./configs/com.knollsoft.Rectangle.plist)" ~/Library/Preferences/
run ln -fsv "$(greadlink -f .gitconfig)" ~
run ln -fsv "$(greadlink -f ./configs/.zshrc)" ~
run ln -fsv "$(greadlink -f ./bin)" ~/bin-dotfiles

if ! which fasd >/dev/null 2>&1; then
  git clone --depth 1 https://github.com/clvv/fasd.git ~/.fasd-src
  run pushd ~/.fasd-src || exit
  PREFIX=. run make install
  run mv ~/.fasd-src/bin/fasd ~/bin/fasd
  run popd || exit
fi

;;
linux)

run ln -fsv "$(readlink -f .gitconfig)" ~
run ln -fsv "$(readlink -f ./bin-dotfiles)" ~

run git remote remove origin
run git remote add origin git@github.com:stephen/dotfiles.git

esac

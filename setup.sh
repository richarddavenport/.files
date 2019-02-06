#! /usr/bin/env zsh

# Check for Homebrew and install if we don't have it
if ! type "brew" > /dev/null; then
  case `uname` in
    Darwin)
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    ;;
    *)
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
    ;;
  esac
fi

brew install zsh
brew install coreutils

# if macos and does not contain brew zsh as standard shell
if [ "$(tail -1 /etc/shells)" != $(which zsh) ]; then
  echo $(which zsh) | sudo tee -a /etc/shells
fi

chsh -s $(which zsh)

\gcp -afrs ~/.files/home/.* ~

# possibly run .brew
# possibly run .macos

# setup would be done at this point...baring any issue

#! /usr/bin/env zsh

chsh -s /bin/zsh

brew reinstall zsh

# if macos and does not contain brew zsh as standard shell
if [ "$(tail -1 /etc/shells)" != "/usr/local/bin/zsh" ]; then
  echo /usr/local/bin/zsh | sudo tee -a /etc/shells
fi

chsh -s /usr/local/bin/zsh

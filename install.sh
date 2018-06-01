#!/bin/bash

REMOTE_URL="git@github.com:getumen/dotfiles.git"

set -e

#This file is modified from https://raw.githubusercontent.com/riobard/dotfiles/master/setup
# exit bash if any command fails

if [ -z $1 ]; then

  # The following path detection code is copied from StackOverflow [1]. It is
  # licensed under GPL 2.0.
  #
  # <http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/179231#179231>.

  # test if this script is from a file or a pipe
  if [ -z ${BASH_SOURCE[0]} ]; then
    # from a pipe
    DOTFILES=~/.dotfiles
  else
    # from a file
    SCRIPT_PATH="${BASH_SOURCE[0]}"
    if ([ -h "${SCRIPT_PATH}" ]) then
      while ([ -h "${SCRIPT_PATH}" ]) do
        SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`
      done
    fi
    pushd . > /dev/null
    cd `dirname ${SCRIPT_PATH}` > /dev/null
    SCRIPT_PATH=`pwd`;
    popd  > /dev/null
    DOTFILES=$SCRIPT_PATH
  fi
else
  DOTFILES=$1
fi

echo Installing dotfiles into $DOTFILES


download() {
  if ! [[ -d $DOTFILES ]]; then
    echo "Downloading dotfiles..."
    git clone $1 $2
  else
    echo "pulling dotfiles"
    cd $2
    git pull
  fi
  return 0
}

has() {
  type "$1" > /dev/null 2>&1
}

link() {
  if [ -h ~/.$1 ]; then
    # symlink already exists but different, backup
    if [ "$(readlink ~/.$1)" != "$DOTFILES/files/$1" ]; then
      mv ~/.$1 ~/.$1.old
    else
      return 0
    fi
  elif [ -f ~/$1 ]; then
    # file/dir already exists. backup it and symlink to the new one
    mv ~/.$1 ~/.$1.old
  fi

  ln -s $DOTFILES/files/$1  ~/.$1
  echo ~/.$1 linked
  return 0
}


linkall() {
  for each in $DOTFILES/files/*; do
    if [ -e $each ]; then
      link `basename $each`
    fi
  done
  return 0
}

download "${REMOTE_URL}" "${DOTFILES}"
linkall

download https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
download https://github.com/pyenv/pyenv.git ~/.pyenv

if [ -d $HOME/.sdkman ]; then
  echo "sdkman found!"
else
  echo "sdkman not found"
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

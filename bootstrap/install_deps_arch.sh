#!/usr/bin/env bash

set -e

install_pacaur() {
  if ! is_installed pacaur
  then
    local dir=$(mktemp -d)
    cd $dir

    info "Installing Cower..."
    curl -o PKGBUILD_cower https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
    makepkg --skippgpcheck -p PKGBUILD_cower
    sudo pacman --noconfirm -U cower*.tar.xz
    ok "Successfully installed Cower"

    info "Installing Pacaur..."
    curl -o PKGBUILD_pacaur https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
    makepkg -p PKGBUILD_pacaur
    sudo pacman --noconfirm -U pacaur*.tar.xz
    ok "Successfully installed Pacaur"

    cd $DOTFILES_ROOT
  fi
}

install_zsh() {
  if ! is_installed zsh
  then
    info "Zsh is not installed yet. Installing..."
    sudo pacman --noconfirm -S zsh
    ok "Successfully installed zsh!"
  fi

  if [[ ! -d "$ZSH" ]]
  then
    info "Oh-My-Zsh is not installed yet. Installing..."
    git clone -q git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh > /dev/null
    ok "Successfully installed Oh-My-Zsh"
  else
    ok "Oh-My-Zsh is already installed"
  fi

  info "Switching default shell to Zsh"
  chsh -s "$(which zsh)"
}

main() {
  source $DOTFILES_ROOT/bootstrap/utils.sh

  sudo pacman --noconfirm -S \
    xorg-server \
    xorg-xinit \
    xorg-xrandr \
    xorg-xbacklight \
    expac \
    yajl \
    git \
    base-devel \
    termite \
    wget \
    curl \
    maim \
    scrot \
    imagemagick \
    feh \
    xclip \
    numlockx \
    networkmanager

  install_pacaur
  pacaur --noconfirm --noedit -S \
    go \
    rust \
    cargo \
    python \
    ruby \
    lua \
    tcl \
    ttf-hack \
    ttf-font-awesome \
    ttf-google-fonts-git \
    powerline-fonts-git \
    neovim \
    i3 \
    i3blocks \
    rofi \
    pulseaudio \
    pulseaudio-alsa \
    alsa-utils \
    pavucontrol \
    ranger \
    screenfetch \
    pass

  install_zsh

  # TODO: firefox fix
  # after installing firefox-aurora, we need to cleanup the cache because the BUILDPKG is bad
  # pacaur -S firefox-aurora
  # rm -rf $HOME/.cache/pacaur/firefox-aurora
}

main

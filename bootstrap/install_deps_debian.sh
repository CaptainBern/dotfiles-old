#!/usr/bin/env bash

set -e

HACK_VERSION=${HACK_VERSION:-"2.020"}
FONT_AWESOME_VERSION=${FONT_AWESOME_VERSION:-"4.7.0"}
GO_VERSION=${GO_VERSION:-"1.7.1"}

TESTING=$(cat <<-EOM
deb     http://ftp.debian.org/debian/    testing main contrib non-free
deb-src http://ftp.debian.org/debian/    testing main contrib non-free
deb     http://security.debian.org/      testing/updates  main contrib non-free
EOM
)

BACKPORTS=$(cat <<-EOM
deb http://ftp.debian.org/debian jessie-backports main contrib non-free
EOM
)

configure_apt() {
  if [ ! -f "/etc/apt/sources.list.d/jessie_testing.list" ]
  then
    dir=$(mktemp -d)
    echo "$TESTING" > /tmp/jessie_testing.list
    sudo mv /tmp/jessie_testing.list /etc/apt/sources.list.d/
  fi

  if [ ! -f "/etc/apt/sources.list.d/jessie_backports.list" ]
  then
    echo "$BACKPORTS" > /tmp/jessie_backports.list
    sudo mv /tmp/jessie_backports.list /etc/apt/sources.list.d/
  fi

  sudo apt-get -qq update
}

install_fonts() {
  if [ ! -d "${HOME}/.fonts" ]
  then
    sudo mkdir "${HOME}/.fonts"
  fi

  # install Google Fonts
  if [ ! -d "${HOME}/.fonts/google-fonts" ]
  then
    if ask "Do you wish to install Google Fonts? (All of them)" Y
    then
      local url="https://github.com/google/fonts/archive/master.zip"
      local file="google-fonts.zip"
      local google_fonts="${HOME}/.fonts/google-fonts"
      local dir=$(mktemp -d)

      info "Installing Google Fonts..."

      wget -q -O ${dir}/${file} ${url}
      unzip -qq ${dir}/${file} -d ${dir}
      sudo mkdir -p ${HOME}/.fonts/google-fonts
      sudo mv ${dir}/fonts-master/* ${HOME}/.fonts/google-fonts
      sudo fc-cache -f > /dev/null
      rm -rf ${dir}

      ok "Successfully installed Google Fonts"
    else
      warn "If you install i3 and rxvt-unicode, make sure to change the font settings in $DOTFILES_ROOT/i3/.i3.symlink/config and $DOTFILES_ROOT/system/.Xresources.symlink accordingly!"
    fi
  else
    ok "Google-Fonts is already installed"
  fi

  # install Hack
  if ! is_font_installed "Hack"
  then
    if ask "Do you wish to install Hack?" Y
    then
      local url="https://github.com/chrissimpkins/Hack/releases/download"
      local file="Hack-v${HACK_VERSION/./_}-otf.tar.gz"
      local dir=$(mktemp -d)

      if [ ! -d "${HOME}/.fonts/hack" ]
      then
        sudo mkdir -p ${HOME}/.fonts/hack
      fi
      mkdir ${dir}/otf

      info "Installing Hack..."

      wget -q -O ${dir}/${file} ${url}/v${HACK_VERSION}/${file}
      tar -xzf ${dir}/${file} -C ${dir}/otf
      sudo mv ${dir}/otf/* ${HOME}/.fonts/hack
      sudo fc-cache -f > /dev/null
      rm -rf ${dir}

      ok "Successfully installed Hack $HACK_VERSION"
    else
      warn "If you install i3, make sure to change the font settings in $DOTFILES_ROOT/i3/.i3.symlink/config and $DOTFILES_ROOT/system/.Xresources.symlink accordingly!"
    fi
  else
    ok "Hack is already installed"
  fi

  # install font-awesome
  if ! is_font_installed "FontAwesome"
  then
    if ask "Do you wish to install FontAwesome?" Y
    then
      local url="https://github.com/FortAwesome/Font-Awesome/archive"
      local file="v${FONT_AWESOME_VERSION}.tar.gz"
      local dir=$(mktemp -d)

      if [ ! -d "${HOME}/.fonts/font-awesome" ]
      then
        sudo mkdir -p ${HOME}/.fonts/font-awesome
      fi

      info "Installing FontAwesome..."

      wget -q -O ${dir}/${file} ${url}/${file}
      tar -xzf ${dir}/${file} -C ${dir}
      sudo mv ${dir}/Font-Awesome-${FONT_AWESOME_VERSION}/fonts/* ${HOME}/.fonts/font-awesome
      sudo fc-cache -f > /dev/null
      rm -rf ${dir}

      ok "Successfully installed FontAwesome $FONT_AWESOME_VERSION"
    else
      warn "If you install i3, make sure to change the font settings in $DOTFILES_ROOT/i3/.i3.symlink/config accordingly!"
    fi
  else
    ok "FontAwesome is already installed"
  fi
}

install_golang() {
  if ! is_installed go
  then
    if ask "Do you wish to install Golang?" Y
    then
      local url="https://storage.googleapis.com/golang"
      local file="go${GO_VERSION}.linux-amd64.tar.gz"
      local dir=$(mktemp -d)

      info "Installing Golang..."

      wget -q -P ${dir} ${url}/${file}
      tar -xzf ${dir}/${file} -C ${dir}
      sudo mv ${dir}/go /usr/local
      rm -rf ${dir}

      ok "Successfully installed Golang $GO_VERSION"
    else
      warn "If you install golang yourself, make sure to edit $DOTFILES_ROOT/go/path.zsh accordingly!"
    fi
  else
    ok "Golang is already installed"
  fi
}

install_urxvt() {
  # install urxvt
  if ! is_installed rxvt-unicode
  then
    if ask "Do you wish to install rxvt-unicode?" Y
    then
      info "Installing rxvt-unicode..."
      sudo apt-get -t testing -qq -y install rxvt-unicode
      ok "Successfully installed rxvt-unicode"
    fi
  else
    ok "rxvt-unicode is already installed"
  fi
}

install_i3() {
  if ! is_installed i3
  then
    if ask "Do you wish to install i3?" Y
    then
      info "Installing i3..."
      sudo apt-get -t jessie-backports -qq -y install i3 i3lock suckless-tools
      ok "Successfully installed i3"
    fi
  else
    ok "i3 is already installed"
  fi

  if ! is_installed i3blocks
  then
    if ask "Do you wish to install i3blocks?" Y
    then
      local dir=$(mktemp -d)
      info "Installing i3blocks"
      git clone -q https://github.com/vivien/i3blocks.git ${dir} > /dev/null
      sudo make install -C ${dir}
      rm -rf ${dir}
      ok "Successfully installed i3blocks"
    fi
  else
    ok "i3blocks is already installed"
  fi

  if ! is_installed rofi
  then
    if ask "Do you wish to install Rofi?" Y
    then
      info "Installing Rofi..."
      sudo apt-get -qq -y install rofi
      ok "Successfully installed Rofi"
    else
      warn "If you install i3, make sure to change the settings in $DOTFILES_ROOT/i3/.i3.symlink/config and $DOTFILES_ROOT/.i3/.i3blocks.conf.symlink accordingly!"
    fi
  else
    ok "Rofi is already installed"
  fi
}

main() {
  source $DOTFILES_ROOT/bootstrap/utils.sh

  info "Installing dependencies"

  configure_apt
  if ask "Run apt-get upgrade?" Y
  then
    sudo apt-get -qq -y upgrade
  fi

  sudo apt-get -qq -y install \
    git-core \
    curl \
    wget \
    unzip \
    scrot \
    imagemagick \
    feh \
    network-manager \
    numlockx

  install_fonts
  install_golang
  install_urxvt
  install_i3

  info "Done installing dependencies"
}

main

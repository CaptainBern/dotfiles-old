#!/usr/bin/env bash

set -e

HACK_VERSION=${HACK_VERSION:-"2.020"}
FONT_AWESOME_VERSION=${FONT_AWESOME_VERSION:-"4.7.0"}
GO_VERSION=${GO_VERSION:-"1.7.1"}

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

			if [ ! -d /tmp/google-fonts ]
			then
				mkdir /tmp/google-fonts
			fi

			info "Installing Google Fonts..."

			wget -q -O /tmp/google-fonts/${file} ${url}
			unzip -qq /tmp/google-fonts/${file} -d /tmp/google-fonts
			sudo mkdir -p $google_fonts
			sudo mv /tmp/google-fonts/fonts-master/* $google_fonts
			sudo fc-cache -f > /dev/null
			rm -rf /tmp/google-fonts

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

			if [ ! -d /tmp/hack/otf ]
			then
				mkdir -p /tmp/hack/otf
			fi

			if [ ! -d ${HOME}/.fonts/hack ]
			then
				sudo mkdir -p ${HOME}/.fonts/hack
			fi

			info "Installing Hack..."

			wget -q -O /tmp/hack/${file} ${url}/v${HACK_VERSION}/${file}
			tar -xzf /tmp/hack/${file} -C /tmp/hack/otf
			sudo mv /tmp/hack/otf/* ${HOME}/.fonts/hack
			sudo fc-cache -f > /dev/null
			rm -rf /tmp/hack

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

			if [ ! -d /tmp/font-awesome ]
			then
				mkdir /tmp/font-awesome
			fi

			if [ ! -d ${HOME}/.fonts/font-awesome ]
			then
				sudo mkdir -p ${HOME}/.fonts/font-awesome
			fi

			info "Installing FontAwesome..."

			wget -q -O /tmp/font-awesome/${file} ${url}/${file}
			tar -xzf /tmp/font-awesome/${file} -C /tmp/font-awesome
			sudo mv /tmp/font-awesome/Font-Awesome-${FONT_AWESOME_VERSION}/fonts/* ${HOME}/.fonts/font-awesome
			sudo fc-cache -f > /dev/null
			rm -rf /tmp/font-awesome

			ok "Successfully installed FontAwesome $FONT_AWESOME_VERSION"
		else
			warn "If you install i3, make sure to change the font settings in $DOTFILES_ROOT/i3/.i3.symlink/config accordingly!"
		fi
  else
    ok "FontAwesome is already installed"
	fi
}

install_golang() {
  # install Golang
	if ! is_installed go
	then
		if ask "Do you wish to install Golang?" Y
		then
			local url="https://storage.googleapis.com/golang"
			local file="go${GO_VERSION}.linux-amd64.tar.gz"

			if [ ! -d /tmp/golang ]
			then
				mkdir /tmp/golang
			fi

			info "Installing Golang..."

			wget -q -P /tmp/golang ${url}/${file}
			tar -xzf /tmp/golang/${file} -C /tmp/golang
			sudo mv /tmp/golang/go /usr/local
			rm -rf /tmp/golang

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

			cat > /tmp/jessie_testing.list <<- EOM
			deb     http://ftp.debian.org/debian/    testing main contrib non-free
			deb-src http://ftp.debian.org/debian/    testing main contrib non-free
			deb     http://security.debian.org/      testing/updates  main contrib non-free
			EOM

			sudo cp /tmp/jessie_testing.list /etc/apt/sources.list.d/
			rm /tmp/jessie_testing.list
			sudo apt-get -qq update
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

      echo "deb http://ftp.debian.org/debian jessie-backports main" > /tmp/jessie_backports.list

      sudo cp /tmp/jessie_backports.list /etc/apt/sources.list.d/
      rm /tmp/jessie_backports.list
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
      info "Installing i3blocks"
      git clone -q https://github.com/vivien/i3blocks.git /tmp/i3blocks > /dev/null
      sudo make install -C /tmp/i3blocks
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
  source ~/.dotfiles/bootstrap/utils.sh

  info "Installing dependencies"
  sudo apt-get -qq update
  if ask "Run apt-get upgrade?" Y
  then
    sudo apt-get -qq -y upgrade
  fi

  sudo apt-get -qq -y install \
    git-core \
    curl \
    wget \
    scrot \
    imagemagick \
    feh \
    network-manager

  install_fonts
  install_golang
  install_urxvt
  install_i3

  info "Done installing dependencies"
}

main

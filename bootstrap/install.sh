#!/usr/bin/env bash

set -e

install_deps() {
  if is_installed "lsb_release"
  then
    local distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
  elif [ -f "/etc/os-release" ]
  then
    local distro=$(cat /etc/os-release | sed -n 's/^ID=//p' | tr '[:upper:]' '[:lower:]')
  fi

  if [[ -f "$DOTFILES_ROOT/bootstrap/install_deps_${distro}.sh" ]]
  then
    if ask "Do you wish to install the dependencies for your distro?" Y
    then
      info "Installing dependencies"
      ${DOTFILES_ROOT}/bootstrap/install_deps_${distro}.sh
      info "Done installing dependencies"
      info "If I were you, I'd reboot."
    fi
  else
    warn "Failed to find the dependency-installation script for your distro! (Either install lsb-release or check if your distro is supported!)"
    exit 1
  fi
}

# Credit to https://github.com/holman/dotfiles/
install_dotfiles() {
	info "Installing dotfiles"

	local overwrite_all=false
	local backup_all=false
	local skip_all=false
	for src in $(find -H "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink' -not -path '*.git*')
	do
		dst="$HOME/$(basename "${src%.*}")"
		link_file "$src" "$dst"
	done

	ok "Successfully installed dotfiles!"
}

dotconfig() {
  if [[ -z "$WORKSPACE" ]]
  then
    while true
    do
      echo -n "Please enter your workspace directory: "
      read REPLY </dev/tty

      if [ -d `eval echo ${REPLY//>}` ]
      then
        ok "Setting \$WORKSPACE to $REPLY"
        echo "export WORKSPACE=$REPLY" >> ${HOME}/.dotconfig
        return 0
      else
        warn "$REPLY is not a directory!"
      fi
    done
  fi
}

main() {
	cd "$(dirname "$0")/.."
	export DOTFILES_ROOT=$(pwd -P)

  if [[ "$DOTFILES_ROOT" != "$HOME/.dotfiles" ]]
  then
    echo "Invalid directory! Clone the dotfiles repo into ${HOME}/.dotfiles and run ${HOME}/.dotfiles/bootstrap/install.sh!"
    exit 1
  fi

	source $DOTFILES_ROOT/bootstrap/utils.sh

  install_deps
  install_dotfiles
  dotconfig
}

main

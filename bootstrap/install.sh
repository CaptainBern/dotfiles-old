#!/usr/bin/env bash

set -e

install_zsh() {
	if ! is_installed zsh
	then
		info "Zsh is not installed yet. Installing..."
		sudo apt-get -qq -y install zsh
		info "Switching default shell to Zsh"
		sudo chsh -s $(which zsh)
		ok "Successfully installed Zsh"
	else
		ok "Zsh is already installed"
	fi

	if [[ ! -d "$ZSH" ]]
	then
		info "Oh-My-Zsh is not installed yet. Installing..."
		wget -q https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh > /dev/null
		ok "Successfully installed Oh-My-Zsh"
	else
		ok "Oh-My-Zsh is already installed"
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


main() {
	cd "$(dirname "$0")/.."
	export DOTFILES_ROOT=$(pwd -P)

  if [[ "$DOTFILES_ROOT" != "$HOME/.dotfiles" ]]
  then
    echo "Invalid directory! Clone the dotfiles repo into ${HOME}/.dotfiles and run ${HOME}/.dotfiles/bootstrap/install.sh!"
    exit 1
  fi

	source $DOTFILES_ROOT/bootstrap/utils.sh

  local distro=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
  if [[ -f "$DOTFILES_ROOT/bootstrap/install_deps_${distro}.sh" ]]
  then
    if ask "Do you wish to install the dependencies for your distro?" Y
    then
      ${DOTFILES_ROOT}/bootstrap/install_deps_${distro}.sh
    fi
  else
    warn "Failed to find the dependency-installation script for your distro! ($distro)"
  fi

	install_zsh
	install_dotfiles
	env zsh
}

main

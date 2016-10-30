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
	DOTFILES_ROOT=$(pwd -P)

	source ~/.dotfiles/bootstrap/utils.sh

	install_zsh
	install_dotfiles
	env zsh
}

main
#!/usr/bin/env bash

RESET="\e[0m"
BLUE="\e[34;1m"
YELLOW="\e[33;1m"
GREEN="\e[32;1m"

info() {
	printf "\r [ ${BLUE}INFO${RESET} ] $1\n"
}

warn() {
	printf "\r [ ${YELLOW}WARN${RESET} ] $1\n"
}

ok() {
	printf "\r [  ${GREEN}OK${RESET}  ] $1\n"
}

is_installed() {
	type -p "$1" &> /dev/null
}

is_font_installed() {
	fc-list | grep -q -i "$1"
}

ask() {
  # http://djm.me/ask
  local prompt default REPLY

  while true
  do
    if [ "${2:-}" = "Y" ]
    then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]
    then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question (not using "read -p" as it uses stderr not stdout)
    echo -n "$1 [$prompt] "

    # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
    read REPLY </dev/tty

    # Default?
    if [ -z "$REPLY" ]
    then
      REPLY=$default
    fi

    # Check if the reply is valid
    case "$REPLY" in
      Y*|y*)
        return 0
        ;;
      N*|n*)
        return 1
        ;;
    esac

  done
}

# Credit to https://github.com/holman/dotfiles
link_file () {
  local src=$1 dst=$2

  local overwrite=
	local backup=
	local skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then
    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then
      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then
        skip=true;
      else
        info "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi
    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      ok "removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      ok "moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      ok "skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
    ok "linked $1 to $2"
  fi
}

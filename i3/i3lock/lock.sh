#!/usr/bin/env bash

# Icon stolen from https://github.com/meskarune/i3lock-fancy

set -e
trap cleanup EXIT

LOCK_ICON="${HOME}/.dotfiles/i3/i3lock/lock.png"
IMAGE="$(mktemp XXXXXXXXXXXXXXXX.png)"

usage() {
cat <<EOF
usage: $(basename $0) [-h] [-i icon]
  general:
    -h, --help    print this message
    -i, --icon    set the icon
EOF
}

cleanup() {
  rm $IMAGE
}

lock() {
  scrot $IMAGE
  convert $IMAGE -level 0%,100%,0.6 -scale 10% -scale 1000% $IMAGE

  if [[ -f $LOCK_ICON ]]
  then
      convert $IMAGE $LOCK_ICON -gravity center -composite $IMAGE
  fi

  i3lock -n -u -f -t -i $IMAGE
}

main() {
  until [[ -z $1 ]]
  do
    case $1 in
      -h|--help )
        usage
        exit 0
        ;;
      -i|--icon )
        shift
        LOCK_ICON=$1
        ;;
      * )
        echo "Invalid option '$1'"
        exit 1
        ;;
    esac
    shift
  done

  lock
}

main $@

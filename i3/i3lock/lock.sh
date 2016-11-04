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
  convert $IMAGE -scale 10% -scale 1000% $IMAGE

  if [[ -f $LOCK_ICON ]]
  then
      # placement x/y
      PX=0
      PY=0
      # lockscreen image info
      R=$(file $LOCK_ICON | grep -o '[0-9]* x [0-9]*')
      RX=$(echo $R | cut -d' ' -f 1)
      RY=$(echo $R | cut -d' ' -f 3)

      SR=$(xrandr --query | grep ' connected' | cut -f3 -d' ')
      for RES in $SR
      do
          # monitor position/offset
          SRX=$(echo $RES | cut -d'x' -f 1)                   # x pos
          SRY=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 1)  # y pos
          SROX=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 2) # x offset
          SROY=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 3) # y offset
          PX=$(($SROX + $SRX/2 - $RX/2))
          PY=$(($SROY + $SRY/2 - $RY/2))

          convert $IMAGE -level 0%,100%,0.6 $LOCK_ICON -geometry +$PX+$PY -composite -matte $IMAGE
      done
  fi

  i3lock -n -u -t -i $IMAGE
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

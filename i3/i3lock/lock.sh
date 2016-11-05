#!/usr/bin/env bash

# Icons stolen from https://github.com/meskarune/i3lock-fancy

set -e
trap cleanup EXIT

LOCK_ICON="${HOME}/.dotfiles/i3/i3lock/lock.png"
DARK_LOCK_ICON="${HOME}/.dotfiles/i3/i3lock/lockdark.png"
THRESHOLD=60
IMAGE="$(mktemp XXXXXXXXXXXXXXXX.png)"

usage() {
cat <<EOF
usage: $(basename $0) [-h] [-i icon] [-di dark-icon] [-t threshold]
  general:
    -h, --help          print this message
    -i, --icon          set the icon
    -d, --dark-icon     the dark icon to use in case the background brightness
                        is greater than the specified threshold
    -t, --threshold     if the background brightness is greater than this value,
                        then the dark-icon will be used instead of the default one.
EOF
}

cleanup() {
  rm $IMAGE
}

lock() {
  scrot $IMAGE
  convert $IMAGE -level 0%,100%,0.6 -scale 10% -scale 1000% $IMAGE

  lock_icon=$LOCK_ICON
  brightness=$(convert $IMAGE -colorspace gray -format "%[fx:100*mean]%%" info:)
  if [ "${brightness%%.*}" -gt "$THRESHOLD" ]
  then
    lock_icon=$DARK_LOCK_ICON
  fi

  if [[ -f $lock_icon ]]
  then
      # placement x/y
      PX=0
      PY=0
      # lockscreen image info
      R=$(file $lock_icon | grep -o '[0-9]* x [0-9]*')
      RX=$(echo $R | cut -d' ' -f 1)
      RY=$(echo $R | cut -d' ' -f 3)

      SR=$(xrandr --query | grep ' connected' | sed 's/primary //' | cut -f3 -d' ')
      for RES in $SR
      do
          # monitor position/offset
          SRX=$(echo $RES | cut -d'x' -f 1)                   # x pos
          SRY=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 1)  # y pos
          SROX=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 2) # x offset
          SROY=$(echo $RES | cut -d'x' -f 2 | cut -d'+' -f 3) # y offset
          PX=$(($SROX + $SRX/2 - $RX/2))
          PY=$(($SROY + $SRY/2 - $RY/2))

          convert $IMAGE $lock_icon -geometry +$PX+$PY -composite -matte $IMAGE
      done
  fi

  i3lock -n -f -t -i $IMAGE
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
    -d|--dark-icon  )
        shift
        DARK_LOCK_ICON=$1
        ;;
    -t|--threshold  )
        shift
        THRESHOLD=$1
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

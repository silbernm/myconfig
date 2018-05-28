#!/bin/sh -eu
#
# stolen from: https://github.com/xmonad/xmonad-testing/blob/master/bin/run-in-xephyr.sh

################################################################################
usage () {
  cat <<EOF
Usage: run-in-xephyr.sh [options]

  -d NxN  Set the screen size to NxN
  -h      This message
  -n NUM  Set the internal DISPLAY to NUM
  -s NUM  Set the number of screens to NUM
  -b BINARY
EOF
}

################################################################################
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
SCREENS=1
SCREEN_SIZE="800x600"
DISPLAY_NUMBER=5

################################################################################
while getopts "hs:b:" o; do
  case "${o}" in
    h) usage
       exit
       ;;
    n) DISPLAY_NUMBER=$OPTARG
       ;;
    s) SCREENS=$OPTARG
       ;;
    b) BINARY=$OPTARG
       ;;
    *) echo; usage
       exit 1
       ;;
  esac
done

shift $((OPTIND-1))

################################################################################
TMPDIR=$(mktemp -d)
XMONAD_CONFIG_DIR=$TMPDIR/state/config
XMONAD_CACHE_DIR=$TMPDIR/state/cache
XMONAD_DATA_DIR=$TMPDIR/state/data
export XMONAD_CONFIG_DIR XMONAD_CACHE_DIR XMONAD_DATA_DIR

mkdir -p "$XMONAD_CONFIG_DIR" "$XMONAD_CACHE_DIR" "$XMONAD_DATA_DIR"
echo "xmonad will store state files in $(pwd)/state"

################################################################################
SCREEN_COUNTER=0
SCREEN_OPTS=""
X_OFFSET_CURRENT="0"
X_OFFSET_ADD=$(echo "$SCREEN_SIZE" | cut -dx -f1)

while expr "$SCREEN_COUNTER" "<" "$SCREENS"; do
  SCREEN_OPTS="$SCREEN_OPTS -origin ${X_OFFSET_CURRENT},0 -screen ${SCREEN_SIZE}+${X_OFFSET_CURRENT}"
  SCREEN_COUNTER=$(("$SCREEN_COUNTER" + 1))
  X_OFFSET_CURRENT=$(("$X_OFFSET_CURRENT" + "$X_OFFSET_ADD"))
done

(
  # shellcheck disable=SC2086
  Xephyr $SCREEN_OPTS +xinerama +extension RANDR \
         -ac -br -reset -terminate -verbosity 10 \
         -softCursor ":$DISPLAY_NUMBER" &

  export DISPLAY=":$DISPLAY_NUMBER"
  echo "Waiting for windows to appear..." && sleep 2

  xterm -hold xrandr &
  xterm &
  $BINARY
)

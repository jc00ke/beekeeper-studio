#!/usr/bin/env bash
# set this for debugging
# set -euxo pipefail

CLONE=/proc/sys/kernel/unprivileged_userns_clone

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"


# taken from the VSCode implementation
# https://aur.archlinux.org/cgit/aur.git/commit/?h=visual-studio-code-bin&id=a0595836467bb205fcabb7e6d44ad7da82b29ed2
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}

# Allow users to override command-line options
if [[ -f $XDG_CONFIG_HOME/bks-flags.conf ]]; then
  echo "launcher-script: found bks-flags.conf"
  USER_FLAGS="$(cat $XDG_CONFIG_HOME/bks-flags.conf)"
fi


if [ ! -f "$CLONE" ]; then
  exec "$SCRIPT_DIR/beekeeper-studio-bin" $USER_FLAGS "$@"
else
  UNPRIVILEGED_USERNS_ENABLED=$(cat "$CLONE" 2>/dev/null)
  if [[ $UNPRIVILEGED_USERNS_ENABLED == 0 ]]; then
    exec "$SCRIPT_DIR/beekeeper-studio-bin" "--no-sandbox" $USER_FLAGS "$@"
  else
    exec "$SCRIPT_DIR/beekeeper-studio-bin" $USER_FLAGS "$@"
  fi
fi

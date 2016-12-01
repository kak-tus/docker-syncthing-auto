#!/usr/bin/env sh

if [ -z $1 ]; then
  rm /tmp/skip_sh
  touch /tmp/skip_sh
  exit 0
fi

if [ -z `fgrep $1 /tmp/skip_sh` ]; then
  echo $1 >> /tmp/skip_sh
  echo 1
  exit 0
fi

exit 0

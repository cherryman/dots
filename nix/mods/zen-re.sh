#!/bin/sh
case "$(uname -s)" in
  Darwin) exec /usr/bin/open -na /Applications/Zen.app --args -P re --no-remote "$@" ;;
  Linux) exec zen-browser -P re --no-remote "$@" ;;
esac

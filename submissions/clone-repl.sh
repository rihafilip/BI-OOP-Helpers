#!/bin/bash
# Usage:
#
#   ./clone-repl.sh [clone_base_directory]
#

SCRIPTPATH=$(realpath $(dirname "$0"))

BASEDIR="$1" # can be empty

while :
do
  echo 'Repo'
  read repo

  echo 'Hash'
  read hash

  "$SCRIPTPATH/clone.sh" "$repo" "$hash" "$BASEDIR"
done

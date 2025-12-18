#!/bin/bash

SCRIPTPATH=$(realpath $(dirname "$0"))

while :
do
  echo 'Repo'
  read repo

  echo 'Hash'
  read hash

  "$SCRIPTPATH/clone.sh" "$repo" "$hash"
done

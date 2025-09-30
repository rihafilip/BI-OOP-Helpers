#!/bin/bash

while :
do
  echo 'Repo'
  read repo

  echo 'Hash'
  read hash

  ./clone.sh "$repo" "$hash"
done

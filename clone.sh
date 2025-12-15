#!/bin/bash

set -e

if [[ -z "$1" ]]; then
  echo "Missing args"
  exit 1
elif [[ -z "$2" ]]; then
  echo "Missing hash"
  exit 1
fi

username=$(echo "$1" | rg 'https://gitlab.fit.cvut.cz/([^/]*)/(.*)' -or '$1')
repo=$(    echo "$1" | rg 'https://gitlab.fit.cvut.cz/([^/]*)/(.*)' -or '$2')

if $(echo $repo | rg -q '.*\.git' ); then
  repo=$repo
else
  repo="$repo.git"
fi

sshlink="git@gitlab.fit.cvut.cz:$username/$repo"

dirname=$(echo "$repo" | rg ".*/([^/]+)\.git" -or '$1')

echo "username=$username"
echo "sshlink=$sshlink"
echo "commit=$2"

git clone "$sshlink" "$dirname"

cd "$username"

git checkout -b "Submission" "$2"

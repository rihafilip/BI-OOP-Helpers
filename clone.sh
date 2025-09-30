#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Missing args"
  exit 1
elif [[ -z "$2" ]]; then
  echo "Missing hash"
  exit 1
fi

username=$(echo "$1" | rg 'https://gitlab.fit.cvut.cz/([^/]*)/([^/]*)' -or '$1')
repo=$(echo "$1" | rg 'https://gitlab.fit.cvut.cz/([^/]*)/([^/]*)(.git)?' -or '$2')

if $(echo $repo | rg -q '.*\.git' ); then
   repo=$repo
else
  repo="$repo.git"
fi

sshlink="git@gitlab.fit.cvut.cz:$username/$repo"

echo username=$username
echo sshlink=$sshlink
echo commit=$2

git clone "$sshlink" "$username"

cd "$username"

git check -b "Submission" "$2"

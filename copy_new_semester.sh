#!/bin/bash

if [[ "$#" -lt 2 ]]; then
  echo "Usage: $0 source-semester destination-semester"
  exit 1
fi

SOURCE_SEMESTER="$1"
DESTINATION_SEMESTER="$2"

tmpdir=$(mktemp -d)

pushd "$tmpdir" > /dev/null

repos="Labs/Lab-1 Labs/Lab-2 Labs/Lab-3 Labs/Dad-Joke-DB Labs/Teacher-notes semestral-project-template"

for repo in $repos; do
  from="git@gitlab.fit.cvut.cz:BI-OOP/$SOURCE_SEMESTER/$repo.git"
  to="git@gitlab.fit.cvut.cz:BI-OOP/$DESTINATION_SEMESTER/$repo.git"

  echo "Cloning from $from to $to"

  git clone --mirror "git@gitlab.fit.cvut.cz:BI-OOP/$SOURCE_SEMESTER/$repo.git" dir
  cd dir
  git remote set-url --push origin "git@gitlab.fit.cvut.cz:BI-OOP/$DESTINATION_SEMESTER/$repo.git"
  git push --mirror
  cd ..
  rm -rf dir
done

popd > /dev/null
rm -rf "$tmpdir"

echo "*********"
echo "Run was succesful - don't forget to set the correct permissions"
echo "*********"

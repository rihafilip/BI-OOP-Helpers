#!/bin/bash

set -e

CONTAINER_NAME="oop-corrector"

if [[ -z "$1" ]]; then
  echo "Missing repository"
  exit 1
elif [[ -z "$2" ]]; then
  echo "Missing commit"
  exit 1
fi

REPOSITORY="$1"
COMMIT="$2"

# Fixup the repo from http to ssh
if echo "$REPOSITORY" | rg -q 'https://gitlab.fit.cvut.cz/'; then
  FULLPATH=$(echo "$REPOSITORY" | rg 'https://gitlab.fit.cvut.cz/([^\.]*)(.git)?' -or '$1')
  REPOSITORY="git@gitlab.fit.cvut.cz:$FULLPATH.git"

elif echo "$REPOSITORY" | rg -q 'git@gitlab.fit.cvut.cz:.*\.git'; then
  FULLPATH=$(echo $REPOSITORY | rg 'git@gitlab.fit.cvut.cz:(.*)\.git' -or '$1')

else
  echo "Malformed repository"
  exit 1
fi

# Extract the student name
DIRNAME=$(echo "$REPOSITORY" | rg ".*/([^/]+)\.git" -or '$1')
if [[ -z "$DIRNAME" ]]; then
  echo "Dirname is empty"
  exit 1
fi

# Log
echo "REPOSITORY=$REPOSITORY"
echo "DIRNAME=$DIRNAME"
echo "COMMIT=$2"

# Clone and checkout
if [[ -e "$DIRNAME" ]]; then
  echo "Already cloned"
else
  git clone "$REPOSITORY" "$DIRNAME" > /dev/null

  cd "$DIRNAME"

  git checkout -b "Submission" "$COMMIT" > /dev/null
fi


# Run the test container
# docker run --mount type=bind,source=$SSH_AUTH_SOCK,target=/ssh-agent \
#             --env SSH_AUTH_SOCK=/ssh-agent \
#             --env REPOSITORY="$REPOSITORY" \
#             --env COMMIT="$COMMIT" \
#             $CONTAINER_NAME 2>&1 | tee ./test_output

# Open the repo

xdg-open "https://gitlab.fit.cvut.cz/$FULLPATH"

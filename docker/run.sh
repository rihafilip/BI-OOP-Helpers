#!/bin/bash

set -e

if [[ -z "$REPOSITORY" ]]; then
  echo "No repository provided!"
  exit 1
fi

mkdir -p /opt/project

git clone "$REPOSITORY" /opt/project
cd /opt/project

if [[ -n "$COMMIT" ]]; then
  git switch --detach "$COMMIT"
fi

# Allow tests to fail
sbt --warn coverage test || true

sbt coverageReport | \
  grep --extended -o \
  "(Statement coverage|Branch coverage)\.*: [[:digit:]]+\.?[[:digit:]]*%"

cloc --quiet --hide-rate ./src

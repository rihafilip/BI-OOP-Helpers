#!/usr/bin/env bash

set -e

SCRIPTPATH=$(realpath $(dirname "$0"))

if [[ -z "$1" ]]; then
  echo "Missing input file"
  exit 1
fi

INPUT_FILE="$1"

GIT_URL_COLUMN="Git clone URL"
COMMIT_COLUMN="The whole commit hash we should consider"

mlr --csv --headerless-csv-output \
  cut -f "$GIT_URL_COLUMN","$COMMIT_COLUMN" \
  "$INPUT_FILE" \
  | while IFS=',' read -r REPOSITORY COMMIT; do
    "$SCRIPTPATH/clone.sh" "$REPOSITORY" "$COMMIT"
  done

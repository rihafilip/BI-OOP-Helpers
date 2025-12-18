#!/usr/bin/env bash

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
    ./clone "$REPOSITORY" "$COMMIT"
  done

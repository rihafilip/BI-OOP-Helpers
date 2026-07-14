#!/usr/bin/env bash
#
#   ./clone-csv.sh csv-file [clone_base_directory]
#
# Environment variables:
#   SEP - the separator of input csv-file, by default comma ","
#

set -e

SCRIPTPATH=$(realpath $(dirname "$0"))

if [[ -z "$1" ]]; then
  echo "Missing input file"
  exit 1
fi

INPUT_FILE="$1"
BASEDIR="$2" # can be empty

if [[ -z "$SEP" ]]; then
  SEP=comma
fi

GIT_URL_COLUMN="Git clone URL"
COMMIT_COLUMN="The whole commit hash we should consider"

cat "$INPUT_FILE" \
  | mlr --csv --ofs=comma --ifs=$SEP filter '($My == "y")' \
  | mlr --csv --headerless-csv-output --ofs=comma --ifs=comma cut -f "$GIT_URL_COLUMN,$COMMIT_COLUMN" \
  | while IFS=',' read -r REPOSITORY COMMIT; do
    "$SCRIPTPATH/clone.sh" "$REPOSITORY" "$COMMIT" "$BASEDIR"
  done

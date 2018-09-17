#!/bin/bash

if [[ "$1" = "--repodir="* ]]; then
  REPODIR="${1/--repodir=/}"
  shift
else
  echo "No repodir given."
  exit 1
fi

for file in "$@"
do
  BASE=${file##*/}
  DIR=${file%$BASE}
  DIRC=${DIR//\//}
  SOURCEDIR="$REPODIR/$DIRC/sources"
  if ! rpmbuild --undefine=_disable_source_fetch -bs "$file" --define "_sourcedir ${SOURCEDIR}"
  then
    exit 1
  fi
done

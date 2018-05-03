#!/bin/bash

if ! BRANCH=$(git rev-parse --abbrev-ref HEAD)
then
  exit 1
fi
if [ "$BRANCH" == "master" ]; then
  LIST=$(git log -m -1 --name-only --pretty="format:" | sed '/./,$!d' | awk '/^$/{exit} {print $0}' | sed '/\.spec$/!d')
else
  LIST=$(git diff master..."$BRANCH" --name-only | sed '/\.spec$/!d')
fi
for file in $LIST; do
  if ! rpmlint "$file"
  then
    exit 1
  fi
done

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
echo $LIST

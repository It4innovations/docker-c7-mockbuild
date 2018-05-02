#!/bin/bash

for file in "$@"
do
  if ! rpmbuild --undefine=_disable_source_fetch -bs "$file"
  then
    exit 1
  fi
done

#!/bin/bash

if ! BRANCH=$(git rev-parse --abbrev-ref HEAD)
then
  exit 1
fi
if [ "$BRANCH" == "master" ]; then
  LIST=$(git log -m -1 --name-only --pretty="format:" | sed '/./,$!d' | awk '/^$/{exit} {print $0}' | sed '/\.spec$/!d')
else
  LIST=$(git diff master...$BRANCH --name-only | sed '/\.spec$/!d')
fi
for i in $LIST; do
  RPM_LOCAL=$(rpm -qp --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}" $i)
  RPM_REMOTE="fail2ban-0.11-2.el7.centos"
  rpmdev-vercmp $RPM_LOCAL $RPM_REMOTE
  if [ $? != 11 ]; then
    echo "Building $RPM_LOCAL is not newer then package in the remote yum repository."
    exit 1
  fi
done

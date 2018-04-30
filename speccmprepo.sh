#!/bin/bash

for file in "$@"
do
  RPM_LOCAL=$(rpm -qp --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}" $1)
  RPM_REMOTE="fail2ban-0.11-2.el7.centos.noarch"
  rpmdev-vercmp $RPM_LOCAL $RPM_REMOTE
  if [ $? != 11 ]; then
    echo "Building $RPM_LOCAL is not newer then package in the remote yum repository."
    exit 1
  fi
done

#!/bin/bash

for file in "$@"
do
  RPM_NAME=$(rpm -qp --queryformat "%{NAME}" $file)
  RPM_LOCAL=$(rpm -qp --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}" $file)
  RPM_REMOTE=$(repoquery --pkgnarrow=all --queryformat "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH} $RPM_NAME")
  if [ -z "$RPM_REMOTE" ]; then
    echo "Brand new package $RPM_LOCAL."
    continue
  fi
  rpmdev-vercmp $RPM_LOCAL $RPM_REMOTE
  if [ $? != 11 ]; then
    echo "Building $RPM_LOCAL is not newer then package in the remote yum repository."
    exit 1
  fi
done

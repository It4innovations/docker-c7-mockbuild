#!/bin/bash

for file in "$@"; do
  RPM_NAME=$(rpm -qp --queryformat "%{NAME}" "$file")
  RPM_LOCAL=$(rpm -qp --queryformat "%{NAME}-%{VERSION}-%{RELEASE}" "$file")
  BUILDARCH=$(rpm2cpio "$file" | cpio -civ --to-stdout '*.spec' | grep BuildArch | cut -d ":" -f2- | tr -d '[:space:]')
  MOCKTARGETS=$(rpm2cpio "$file" | cpio -civ --to-stdout '*.spec' | grep "#mocktargets:" | cut -d ":" -f2)
  if ! [ -z "$BUILDARCH" ]; then
    if ! [ "$BUILDARCH" = "noarch" ]; then
      echo "$file: only BuildArch: noarch is allowed, however $BUILDARCH is given."
      exit 1
    fi
    if [ "$(echo "$MOCKTARGETS" | grep -cEo "\w+\-[0-9]+\-noarch")" -eq 0 ]; then
      MOCKTARGETS="centos-7-noarch"
    fi
    MOCKTARGETS=$(echo "$MOCKTARGETS" | grep -Eo "\w+\-[0-9]+\-noarch" | sort | uniq)
  fi

  for target in $MOCKTARGETS; do
    RELEASESERVER=$(echo "$target" | grep -Eo "\-[0-9]+\-" | grep -Eo "[0-9]+")
    ARCH=$(echo "$target" | grep -Eo "\w+$")
    RPM_REMOTE=$(repoquery --pkgnarrow=all --releaseserver="$RELEASESERVER" --archlist="$ARCH" --queryformat "%{NAME}-%{VERSION}-%{RELEASE}" "$RPM_NAME"."$ARCH")
    if [ -z "$RPM_REMOTE" ]; then
      echo "Brand new package $RPM_LOCAL.$ARCH"
      continue
    fi
    rpmdev-vercmp "$RPM_LOCAL" "$RPM_REMOTE"
    if [ $? != 11 ]; then
      echo "Building $RPM_LOCAL.$ARCH is not newer then package in the remote yum repository."
      exit 1
    fi
    RPM_REMOTE=$(repoquery --pkgnarrow=all --releaseserver="$RELEASESERVER" --srpm --queryformat "%{NAME}-%{VERSION}-%{RELEASE}" "$RPM_NAME")
    if [ -z "$RPM_REMOTE" ]; then
      echo "Brand new source package $RPM_LOCAL.$ARCH"
      continue
    fi
    rpmdev-vercmp "$RPM_LOCAL" "$RPM_REMOTE"
    if [ $? != 11 ]; then
      echo "Building source $RPM_LOCAL.$ARCH is not newer then package in the remote yum repository."
      exit 1
    fi
  done
done

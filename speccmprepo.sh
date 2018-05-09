#!/bin/bash

for file in "$@"; do
  RPM_NAME=$(rpm -qp --queryformat "%{NAME}" "$file")
  RPM_LOCAL=$(rpm -qp --queryformat "%{NAME}-%{VERSION}-%{RELEASE}" "$file" | sed "s/.centos//")
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
    DIST=$(echo "$target" | grep -Eo "^\w+")
    ARCH=$(echo "$target" | grep -Eo "\w+$")
    REPOPATH="http://repository.it4i.cz/it4irepo/$DIST/$RELEASESERVER/stable/"
    RPM_REMOTE=$(repoquery --pkgnarrow=all --archlist=src --repofrompath=it4irepo,"$REPOPATH"SRPMS/ --queryformat "%{NAME}-%{VERSION}-%{RELEASE}" "$RPM_NAME")
    if [ -z "$RPM_REMOTE" ]; then
      echo "Brand new source package $RPM_LOCAL"
    else
      rpmdev-vercmp "$RPM_LOCAL" "$RPM_REMOTE"
      if [ $? != 11 ]; then
        echo "Building source package $RPM_LOCAL is not newer then package in the remote yum repository."
        exit 1
      fi
    fi
    RPM_REMOTE=$(repoquery --pkgnarrow=all --repofrompath=it4irepo,"$REPOPATH""$ARCH"/ --queryformat "%{NAME}-%{VERSION}-%{RELEASE}" "$RPM_NAME"."$ARCH")
    if [ -z "$RPM_REMOTE" ]; then
      echo "Brand new package $RPM_LOCAL.$ARCH"
    else
      rpmdev-vercmp "$RPM_LOCAL"."$ARCH" "$RPM_REMOTE"."$ARCH"
      if [ $? != 11 ]; then
        echo "Building $RPM_LOCAL.$ARCH is not newer then package in the remote yum repository."
        exit 1
      fi
    fi
  done
done

FROM centos:centos7

MAINTAINER Marek Chrastina <marek.chrastina@vsb.cz>

RUN yum clean all && yum update -y
RUN yum -y install wget git dos2unix rpmlint
ADD ./speclint4git.sh /root
RUN ln -s /root/speclint4git.sh /usr/bin/speclint4git
RUN chmod a+x /root/speclint4git.sh

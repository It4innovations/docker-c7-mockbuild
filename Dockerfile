FROM centos:centos7

MAINTAINER Marek Chrastina <marek.chrastina@vsb.cz>

RUN yum clean all && yum update -y
RUN yum -y groups install "Development Tools"
RUN yum -y install wget git dos2unix rpmlint mock

RUN useradd -G mock builder && chmod g+w /etc/mock/*.cfg
#USER builder
#ENV HOME /home/builder

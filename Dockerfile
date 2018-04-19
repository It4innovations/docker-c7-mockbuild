FROM centos:centos7

MAINTAINER Marek Chrastina

RUN yum clean all && yum update -y && yum install -y epel-release
RUN yum -y groups install "Development Tools"
RUN yum -y install wget mock git dos2unix rpmlint

RUN useradd -G mock builder && chmod g+w /etc/mock/*.cfg

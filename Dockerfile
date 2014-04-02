FROM ubuntu:precise
MAINTAINER Rhommel Lamas <roml@rhommell.com>

## Variables
ENV OPENRESTY_VERSION 1.5.8.1
ENV DEBIAN_FRONTEND noninteractive
ENV PROVIDER_ID 2445580392072

## Repositories
RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu precise-updates universe' >> /etc/apt/sources.list && \
    apt-get update

## Install supervisord
RUN apt-get install -y openssh-server supervisor
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

## UTILITIES
RUN apt-get install -y vim wget build-essential

## OPENRESTY DEPENDENCIES
RUN apt-get install -y libreadline-dev libncurses5-dev libpcre3 libpcre3-dev libssl-dev

## INSTALL OPENRESTY
RUN wget --quiet http://openresty.org/download/ngx_openresty-$OPENRESTY_VERSION.tar.gz && \
    tar xzf ngx_openresty-$OPENRESTY_VERSION.tar.gz && \
    rm ngx_openresty-$OPENRESTY_VERSION.tar.gz && \
    cd ngx_openresty-$OPENRESTY_VERSION && \
    ./configure --prefix=/opt/openresty --with-http_iconv_module -j2 && \
    make && make install

RUN mkdir -p /opt/3scale/log

ADD conf/nginx_$PROVIDER_ID.conf /opt/3scale/nginx.conf
ADD conf/nginx_$PROVIDER_ID.lua /opt/3scale/nginx_$PROVIDER_ID.lua
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 80

CMD [ "/usr/bin/supervisord", "-n"]
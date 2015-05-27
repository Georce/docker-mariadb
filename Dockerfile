FROM index.alauda.cn/dockerlibrary/centos:6.6
MAINTAINER sameer@damagehead.com & wujian@wujian360.cn

RUN \cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY mariadb.repo /etc/yum.repos.d/mariadb.repo

RUN yum install -y MariaDB MariaDB-devel

ADD start /start
RUN chmod 755 /start

EXPOSE 3306

VOLUME ["/var/lib/mysql"]
VOLUME ["/run/mysqld"]

CMD ["/start"]

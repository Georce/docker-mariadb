[![Circle CI](https://circleci.com/gh/sameersbn/docker-mysql.svg?style=svg)](https://circleci.com/gh/sameersbn/docker-mysql)

# Table of Contents

- [Introduction](#introduction)
- [Contributing](#contributing)
- [Changelog](Changelog.md)
- [Reporting Issues](#reporting-issues)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Data Store](#data-store)
- [Creating User and Database at Launch](#creating-user-and-database-at-launch)
- [Creating remote user with privileged access](#creating-remote-user-with-privileged-access)
- [Shell Access](#shell-access)
- [Upgrading](#upgrading)

# Introduction

Dockerfile to build a MySQL container image which can be linked to other containers.

# Contributing

If you find this image useful here's how you can help:

- Send a Pull Request with your awesome new features and bug fixes
- Help new users with [Issues](https://github.com/georce/docker-mariadb/issues) they may encounter
- Send me a tip via [Bitcoin](https://www.coinbase.com/sameersbn) or using [Gratipay](https://gratipay.com/sameersbn/)

# Reporting Issues

Docker is a relatively new project and is active being developed and tested by a thriving community of developers and testers and every release of docker features many enhancements and bugfixes.

Given the nature of the development and release cycle it is very important that you have the latest version of docker installed because any issue that you encounter might have already been fixed with a newer docker release.

For ubuntu users I suggest [installing docker](https://docs.docker.com/installation/ubuntulinux/) using docker's own package repository since the version of docker packaged in the ubuntu repositories are a little dated.

Here is the shortform of the installation of an updated version of docker on ubuntu.

```bash
sudo apt-get purge docker.io
curl -s https://get.docker.io/ubuntu/ | sudo sh
sudo apt-get update
sudo apt-get install lxc-docker
```

Fedora and RHEL/CentOS users should try disabling selinux with `setenforce 0` and check if resolves the issue. If it does than there is not much that I can help you with. You can either stick with selinux disabled (not recommended by redhat) or switch to using ubuntu.

If using the latest docker version and/or disabling selinux does not fix the issue then please file a issue request on the [issues](https://github.com/georce/docker-mariadb/issues) page.

In your issue report please make sure you provide the following information:

- The host ditribution and release version.
- Output of the `docker version` command
- Output of the `docker info` command
- The `docker run` command you used to run the image (mask out the sensitive bits).

# Installation

Pull the latest version of the image from the docker index. This is the recommended method of installation as it is easier to update image in the future. These builds are performed by the **Docker Trusted Build** service.

```bash
docker pull index.alauda.cn/georce/mariadb:latest
```

Alternately you can build the image yourself.

```bash
git clone https://github.com/georce/docker-mariadb.git
cd docker-mariadb
docker build -t="$USER/mariadb" .
```

# Quick Start

Run the mariadb image

```bash
docker run -name mariadb -d index.alauda.cn/georce/mariadb:latest
```

You can access the mysql server as the root user using the following command:

```bash
docker run -it --rm --volumes-from=mariadb index.alauda.cn/georce/mariadb:latest mysql -uroot
```

# Data Store

You should mount a volume at `/var/lib/mysql`.

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /opt/mysql/data
sudo chcon -Rt svirt_sandbox_file_t /opt/mysql/data
```

The updated run command looks like this.

```
docker run -name mariadb -d \
  -v /opt/mysql/data:/var/lib/mysql index.alauda.cn/georce/mariadb:latest
```

This will make sure that the data stored in the database is not lost when the image is stopped and started again.

# Creating User and Database at Launch

To create a new database specify the database name in the `DB_NAME` variable. The following command creates a new database named *dbname*:

```bash
docker run --name mariadb -d \
  -e 'DB_NAME=dbname' index.alauda.cn/georce/mariadb:latest
```

You may also specify a comma separated list of database names in the `DB_NAME` variable. The following command creates two new databases named *dbname1* and *dbname2*

```bash
docker run --name mariadb -d \
-e 'DB_NAME=dbname1,dbname2' index.alauda.cn/georce/mariadb:latest
```

To create a new user you should specify the `DB_USER` and `DB_PASS` variables.

```bash
docker run --name mariadb -d \
  -e 'DB_USER=dbuser' -e 'DB_PASS=dbpass' -e 'DB_NAME=dbname' \
  index.alauda.cn/georce/mariadb:latest
```

The above command will create a user *dbuser* with the password *dbpass* and will also create a database named *dbname*. The *dbuser* user will have full/remote access to the database.

**NOTE**
- If the `DB_NAME` is not specified, the user will not be created
- If the user/database user already exists no changes are be made
- If `DB_PASS` is not specified, an empty password will be set for the user

# Creating remote user with privileged access

To create a remote user with privileged access, you need to specify the `DB_REMOTE_ROOT_NAME` and `DB_REMOTE_ROOT_PASS` variables, eg.

```bash
docker run --name mariadb -d \
  -e 'DB_REMOTE_ROOT_NAME=root' -e 'DB_REMOTE_ROOT_PASS=secretpassword' \
  index.alauda.cn/georce/mariadb:latest
```

Optionally you can specify the `DB_REMOTE_ROOT_HOST` variable to define the address space within which remote access should be permitted. This defaults to `172.17.42.1` and should suffice for most cases.

Situations that would require you to override the default `DB_REMOTE_ROOT_HOST` setting are:

- If you have changed the ip address of the `docker0` interface
- If you are using host networking, i.e. `--net=host`, etc.

# Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it mariadb bash
```

If you are using an older version of docker, you can use the [nsenter](http://man7.org/linux/man-pages/man1/nsenter.1.html) linux tool (part of the util-linux package) to access the container shell.

Some linux distros (e.g. ubuntu) use older versions of the util-linux which do not include the `nsenter` tool. To get around this @jpetazzo has created a nice docker image that allows you to install the `nsenter` utility and a helper script named `docker-enter` on these distros.

To install `nsenter` execute the following command on your host,

```bash
docker run --rm -v /usr/local/bin:/target jpetazzo/nsenter
```

Now you can access the container shell using the command

```bash
sudo docker-enter mariadb
```

For more information refer https://github.com/jpetazzo/nsenter

# Upgrading

To upgrade to newer releases, simply follow this 3 step upgrade procedure.

- **Step 1**: Stop the currently running image

```bash
docker stop mariadb
```

- **Step 2**: Update the docker image.

```bash
docker pull index.alauda.cn/georce/mariadb:latest
```

- **Step 3**: Start the image

```bash
docker run -name mariadb -d [OPTIONS] index.alauda.cn/georce/mariadb:latest
```

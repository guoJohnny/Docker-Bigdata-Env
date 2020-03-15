#基于centos6-ssh构建
FROM guojohnny/centos:ssh
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Add jdk8"

# 复制 JDK1.8
ADD jdk-8u221-linux-x64.tar.gz /usr/local/

# 设置 PATH
ENV JAVA_HOME /usr/local/jdk1.8.0_221
ENV PATH $JAVA_HOME/bin:$PATH

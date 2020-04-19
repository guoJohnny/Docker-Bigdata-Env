FROM guojohnny/centos:jdk8
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Zookeeper"

ADD zookeeper-3.4.12.tar.gz /usr/local

# 配置 zookeeper 环境变量
ENV ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.12
ENV PATH $ZOOKEEPER_HOME/bin:$PATH

RUN rm -rf $ZOOKEEPER_HOME/bin/*.cmd  \
	&& rm -rf $ZOOKEEPER_HOME/dist-maven  \
	&& rm -rf $ZOOKEEPER_HOME/docs  \
	&& rm -rf $ZOOKEEPER_HOME/src \
    && cd ${ZOOKEEPER_HOME} \
	&& mkdir data \
	&& mkdir log 

ADD conf-zookeeper/zoo.cfg $ZOOKEEPER_HOME/conf/

# 开放2181端口
EXPOSE 2181

CMD ["sh", "-c", "chmod a+x $ZOOKEEPER_HOME/conf/config.sh; $ZOOKEEPER_HOME/conf/config.sh ; $ZOOKEEPER_HOME/bin/zkServer.sh start-foreground; bash"]
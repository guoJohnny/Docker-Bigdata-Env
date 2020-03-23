FROM guojohnny/centos:hadoop-ha-base
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Hadoop HA."

# 复制定制化配置文件
COPY conf-hadoop-HA/* $HADOOP_CONF_DIR/
COPY conf-zookeeper/zoo.cfg $ZOOKEEPER_HOME/conf

COPY hadoop-ha-entrypoint.sh /usr/bin/
RUN chmod a+x /usr/bin/hadoop-ha-entrypoint.sh \
    && chkconfig iptables off

CMD ["sh", "-c", "/usr/bin/hadoop-ha-entrypoint.sh; bash"]

EXPOSE 2181 2888 3888 8080 50070 8485
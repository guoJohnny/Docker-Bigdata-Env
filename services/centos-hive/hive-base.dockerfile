FROM guojohnny/centos:spark-ha
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Hive based on Hadoop HA Spark HA."

ENV HIVE_HOME=/usr/local/apache-hive-3.1.2
ENV PATH $HIVE_HOME/bin:$PATH

ADD apache-hive-3.1.2-bin.tar.gz /usr/local/

RUN mv /usr/local/apache-hive-3.1.2-bin /usr/local/apache-hive-3.1.2 &&\
    rm -rf $HIVE_HOME/binary-package-licenses && \
    rm -rf $HIVE_HOME/examples &&\
    mkdir -p /usr/local/tmp/hive
# 复制 mysql 包到 lib目录w
COPY mysql-connector-java-5.1.47.jar $HIVE_HOME/lib/

EXPOSE 10000 10002
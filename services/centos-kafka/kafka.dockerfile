FROM guojohnny/centos:zookeeper
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Kafka based on Zookeeper"

ADD kafka_2.12-2.5.0.tgz /usr/local/
COPY kafka-entrypoint.sh /usr/bin/

# 配置 kafka 环境变量
ENV KAFKA_HOME=/usr/local/kafka_2.12-2.5.0
ENV PATH $KAFKA_HOME/bin:$PATH

RUN rm -rf $KAFKA_HOME/site-docs \
	&& mkdir -p  $KAFKA_HOME/log \
    && chmod a+x /usr/bin/kafka-entrypoint.sh

COPY ./conf-kafka/server.properties $KAFKA_HOME/config/

CMD ["sh", "-c", "/usr/bin/kafka-entrypoint.sh; bash"]
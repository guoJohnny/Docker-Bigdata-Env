FROM guojohnny/centos:hadoop-ha
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Spark based on Hadoop HA."

ENV SPARK_HOME=/usr/local/spark-2.4.5
ENV PATH $SPARK_HOME/sbin:$PATH
ENV PATH $SPARK_HOME/bin:$PATH

ADD spark-2.4.5.tgz /usr/local/

RUN mv /usr/local/spark-2.4.5-bin-without-hadoop-scala-2.12 /usr/local/spark-2.4.5 \
    && rm -rf $SPARK_HOME/bin/*.cmd && \
    rm -rf $SPARK_HOME/sbin/*.cmd && \
    rm -rf $SPARK_HOME/ec2 


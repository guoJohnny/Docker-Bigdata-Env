FROM guojohnny/centos:jdk8
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Hadoop HA."

# 复制 hadoop-2.8.3、zookeeper-3.4.12
ADD hadoop-2.8.3.tar.gz /usr/local/
ADD zookeeper-3.4.12.tar.gz /usr/local

# 配置 hadoop 环境变量
ENV HADOOP_HOME=/usr/local/hadoop-2.8.3
ENV PATH $HADOOP_HOME/bin:$PATH
ENV HADOOP_PREFIX=$HADOOP_HOME
ENV HADOOP_COMMON_HOME=$HADOOP_HOME
ENV HADOOP_HDFS_HOME=$HADOOP_HOME
ENV HADOOP_MAPRED_HOME=$HADOOP_HOME
ENV HADOOP_YARN_HOME=$HADOOP_HOME
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop

# 配置 zookeeper 环境变量
ENV ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.12
ENV PATH $ZOOKEEPER_HOME/bin:$PATH

RUN cd $HADOOP_HOME	\
	&& mkdir tmp \
	&& mkdir -p dfs/name \
	&& mkdir -p dfs/data \
	&& rm -rf $HADOOP_HOME/share/docs \
	&& echo "export JAVA_HOME=$JAVA_HOME" >> etc/hadoop/hadoop-env.sh \
	&& echo "export HADOOP_PREFIX=$HADOOP_PREFIX" >> etc/hadoop/hadoop-env.sh \
	&& echo "export JAVA_HOME=$JAVA_HOME" >> etc/hadoop/yarn-env.sh \
	&& cd ${ZOOKEEPER_HOME} \
	&& mkdir data \
	&& mkdir log \
	&& rm -rf $ZOOKEEPER_HOME/bin/*.cmd  \
	&& rm -rf $ZOOKEEPER_HOME/dist-maven  \
	&& rm -rf $ZOOKEEPER_HOME/docs  \
	&& rm -rf $ZOOKEEPER_HOME/src 


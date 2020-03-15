FROM guojohnny/centos:jdk8
LABEL maintainer="guojohnny@chihan.me"
LABEL description="hadoop base setting."

# 复制 hadoop-2.8.3
ADD hadoop-2.8.3.tar.gz /usr/local/

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

RUN cd $HADOOP_HOME	\
	&& mkdir tmp \
	&& mkdir -p dfs/name \
	&& mkdir -p dfs/data \	
	&& echo "export JAVA_HOME=$JAVA_HOME" >> etc/hadoop/hadoop-env.sh \
	&& echo "export HADOOP_PREFIX=$HADOOP_PREFIX" >> etc/hadoop/hadoop-env.sh \
	&& echo "export JAVA_HOME=$JAVA_HOME" >> etc/hadoop/yarn-env.sh \
	&& sed -i 's/localhost/master/g'  etc/hadoop/slaves \
	&& echo "slave1" >> etc/hadoop/slaves	\
	&& echo "slave2" >> etc/hadoop/slaves	

COPY conf/core-site.xml $HADOOP_CONF_DIR
COPY conf/hdfs-site.xml $HADOOP_CONF_DIR
COPY conf/mapred-site.xml $HADOOP_CONF_DIR
COPY conf/yarn-site.xml $HADOOP_CONF_DIR


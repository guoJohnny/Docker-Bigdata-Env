FROM guojohnny/centos:hive-base
LABEL maintainer="guojohnny@chihan.me"
LABEL description="import bash & conf"

COPY hive-entrypoint.sh /usr/bin/
COPY ./conf-hive/* $HIVE_HOME/conf/

RUN chmod a+x /usr/bin/hive-entrypoint.sh &&\
    cp $SPARK_HOME/jars/scala-library-2.12.10.jar $HIVE_HOME/lib &&\
    cp $SPARK_HOME/jars/spark-core_2.12-2.4.5.jar $HIVE_HOME/lib &&\
    cp $SPARK_HOME/jars/spark-network-common_2.12-2.4.5.jar $HIVE_HOME/lib &&\
    cp $SPARK_HOME/jars/spark-unsafe_2.12-2.4.5.jar $HIVE_HOME/lib


CMD ["sh", "-c", "/usr/bin/hive-entrypoint.sh; bash"]

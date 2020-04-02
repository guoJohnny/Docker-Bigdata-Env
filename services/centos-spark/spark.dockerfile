FROM guojohnny/centos:spark-base
LABEL maintainer="guojohnny@chihan.me"
LABEL description="Spark HA"

# 复制定制化配置文件
COPY conf-spark/* $SPARK_HOME/conf/
COPY spark-entrypoint.sh /usr/bin/
RUN chmod a+x /usr/bin/spark-entrypoint.sh 

CMD ["sh", "-c", "/usr/bin/spark-entrypoint.sh; bash"]
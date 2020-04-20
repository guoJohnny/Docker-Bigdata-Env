#!/bin/bash
main(){
    # 修改master2节点的RM启动sleep时长，保证master1节点的RM状态为active。
    sed -i 's/sleep 20/sleep 50/' /usr/bin/hadoop-ha-entrypoint.sh
    # 启动 Hadoop 配置
    cd /usr/bin
    ./hadoop-ha-entrypoint.sh
    
    cd $SPARK_HOME/sbin
    if [ ${HOSTNAME} == "master1" -a ${ROLE} == "master" ];then
        ./start-all.sh 
        jar cv0f /usr/local/lib/spark-libs.jar -C $SPARK_HOME/jars/ .
        hadoop fs -mkdir -p /tmp/spark/lib-jars/
        hadoop fs -put  /usr/local/lib/spark-libs.jar hdfs://master/tmp/spark/lib-jars/
        hadoop fs -mkdir -p /data/wordcount
        hadoop fs -put /home/root/data/myword.txt /data/wordcount
    fi

    if [ ${HOSTNAME} == "master2" -a ${ROLE} == "master" ];then
        ./start-master.sh 
    fi
    
}

main
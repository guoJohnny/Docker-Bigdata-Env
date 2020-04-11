#!/bin/bash

main(){
    # 启动Hadoop前修改core-site.xml配置
    # 解决 beeline 链接 hive2 出现 User: root is not allowed to impersonate hive 错误
    sed -i '$d' $HADOOP_HOME/etc/hadoop/core-site.xml
	echo "<property><name>hadoop.proxyuser.root.hosts</name><value>*</value></property>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
    echo "<property><name>hadoop.proxyuser.root.groups</name><value>*</value></property>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
    echo "</configuration>" >> $HADOOP_HOME/etc/hadoop/core-site.xml
    
    ./usr/bin/spark-entrypoint.sh

    mv $HIVE_HOME/lib/jline-2.12.jar $HADOOP_HOME/share/hadoop/yarn/
    mkdir -p /usr/local/tmp/hive/root
    # 在hadoop中创建hive相应文件
    hadoop fs -mkdir -p /root/hive/sparkeventlog
    hadoop fs -mkdir -p /root/hive/warehouse
    hadoop fs -chmod 777 /root/hive/warehouse
    hadoop fs -mkdir -p /tmp/hive
    hadoop fs -chmod 777 /tmp/hive

    # 生成mysql元数据库，开启服务
    cd $HIVE_HOME/bin
    ./schematool -dbType mysql -initSchema
    ./hive --service hiveserver2 &

}

main
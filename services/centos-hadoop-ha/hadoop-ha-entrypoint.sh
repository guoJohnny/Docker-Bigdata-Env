#!/bin/bash
startZookeeper(){
    echo "${ZK_ID}" >${ZOOKEEPER_HOME}/data/myid
    ${ZOOKEEPER_HOME}/bin/zkServer.sh start-foreground
}

startMaster(){
	sed -i '$d' /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.resourcemanager.ha.id</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml 
	echo "</configuration>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	cd /usr/local/hadoop-2.8.3/sbin		
	if [ ${HOSTNAME} == "master1" ];then
		echo "${HOSTNAME}"
		hdfs zkfc -formatZK		
		hdfs namenode -format		
		./start-dfs.sh && ./start-yarn.sh
		 
	else
		echo "${HOSTNAME}"
		sleep 20
		hdfs namenode -bootstrapStandby	
		./hadoop-daemon.sh start namenode && ./yarn-daemon.sh start resourcemanager
	fi
}

configSlave(){
	# 对 slave nodemanager 地址和 journalnode rpc地址单独做配置
	# 如果不做配置会造成 connection refused ， master 节点连接不到 slave 节点服务。
	# 出现错误环境：docker desktop for mac Version 2.2.1.0 edge
	mkdir -p  /usr/local/hadoop-2.8.3/dfs/data/journal
	sed -i '$d' /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.hostname</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.address</name><value>${HOSTNAME}:9999</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.bind-host</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "</configuration>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	sed -i '$d' /usr/local/hadoop-2.8.3/etc/hadoop/hdfs-site.xml
	echo "<property><name>dfs.journalnode.rpc-address</name><value>${HOSTNAME}:8485</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/hdfs-site.xml
	echo "<property><name>dfs.journalnode.http-address</name><value>${HOSTNAME}:8480</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/hdfs-site.xml
	echo "</configuration>" >> /usr/local/hadoop-2.8.3/etc/hadoop/hdfs-site.xml
}

main(){

	echo "$(sed '1,6d' /etc/hosts)" > /etc/hosts	
	/etc/init.d/sshd restart 
	sleep 5

	if [ ${ROLE} == "slave" ];then
		configSlave
	fi

    if [ ${ZK_ID} ];then
		cd /usr/local/hadoop-2.8.3/sbin	
		./hadoop-daemon.sh start journalnode			
        startZookeeper
    fi

	if [ ${ROLE} == "master" ];then	
		startMaster
	fi
}

main
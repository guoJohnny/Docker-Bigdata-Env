#!/bin/bash

startMaster(){		
	hdfs namenode -format	
	cd /usr/local/hadoop-2.8.3/sbin
	./start-all.sh 
}

configSlave(){
	sed -i '$d' /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.hostname</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.address</name><value>${HOSTNAME}:9999</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.bind-host</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "</configuration>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
}

createWordCount(){
	hadoop fs -mkdir -p /data/wordcount
	hadoop fs -mkdir /output
	touch myword.txt
	echo "leaf yyh" >> myword.txt
	echo "yyh xpleaf" >> myword.txt
	echo "katy ling" >> myword.txt
	echo "yeyonghao leaf" >> myword.txt
	echo "xpleaf katy" >> myword.txt
	hadoop fs -put myword.txt /data/wordcount
	echo "Create Wordcount Done!"
}

main(){

	echo "$(sed '1,6d' /etc/hosts)" > /etc/hosts	

	if [ ${ROLE} == "slave" ];then
		configSlave
	fi
	/etc/init.d/sshd restart 
	sleep 5

	if [ ${ROLE} == "master" ];then	
		startMaster
		createWordCount
	fi
}

main
# Hadoop HA docker 搭建环境记录

# 搭建环境

- MacOSX Mojave 10.14
- docker desktop for Mac 
  - version 2.2.1.0
  - channel edge 
  - Engine 19.03.5
- docker 容器内操作系统镜像 centos7
- Hadoop 2.8.3
- Zookeeper 3.4.12

# 构建 Hadoop HA 集群镜像主要命令
*（配置详见dockerfile及hadoop-ha-entrypoint.sh）*

## 启动 Hadoop HA 命令

```bash
	# 双 master 节点ZK初始化并启动Active、Standby
    cd /usr/local/hadoop-2.8.3/sbin		
	if [ ${HOSTNAME} == "master1" ];then
		echo "${HOSTNAME}"
		hdfs zkfc -formatZK		
		hdfs namenode -format
		./start-dfs.sh && ./start-yarn.sh 
	else
		echo "${HOSTNAME}"
		hdfs zkfc -formatZK
		hdfs namenode -bootstrapStandby	
		./hadoop-daemon.sh start namenode && ./yarn-daemon.sh start resourcemanager
	fi
```

## 在slave节点开启journalnode、Zookeeper服务

```bash
	cd /usr/local/hadoop-2.8.3/sbin	
	./hadoop-daemon.sh start journalnode		
	echo "${ZK_ID}" >${ZOOKEEPER_HOME}/data/myid
    ${ZOOKEEPER_HOME}/bin/zkServer.sh start-foreground
```
## 验证高可用集群节点状态

在不同节点Shell中使用下面两个命令，master1 节点 Active，master2 节点 Standby

```bash
hdfs haadmin -getServiceState master1
yarn rmadmin -getServiceState master1 
```

# 搭建过程中出现的问题

## Retrying connect to server

出现connect refused问题，端口为8485、8480、9000等端口连接不上的问题。主要集中于 JournalNode 节点。Wordcount 例子的 Mapreduce 过程中也会出现这个问题。如果没有在配置中指定 Journalnode 端口，这样即使是在当前 netstat 命令得到在本地有开启相应端口，journalnode 也不允许外部节点访问，造成connect refuse 问题。

如果不显式配置，netstat命令会出现 0.0.0.0:8485、  0.0.0.0:8480、 0.0.0.0:9999，以下是修改后的端口开放。

```shell
[root@slave2 /]# netstat -ntlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name   
tcp        0      0 172.16.0.202:8480           0.0.0.0:*                   LISTEN      46/java             
tcp        0      0 127.0.0.1:50020             0.0.0.0:*                   LISTEN      157/java            
tcp        0      0 0.0.0.0:2181                0.0.0.0:*                   LISTEN      102/java            
tcp        0      0 172.16.0.202:8485           0.0.0.0:*                   LISTEN      46/java             
tcp        0      0 172.16.0.202:8040           0.0.0.0:*                   LISTEN      329/java            
tcp        0      0 172.16.0.202:8042           0.0.0.0:*                   LISTEN      329/java            
tcp        0      0 172.16.0.202:9999           0.0.0.0:*                   LISTEN      329/java            
tcp        0      0 127.0.0.1:44719             0.0.0.0:*                   LISTEN      157/java            
tcp        0      0 172.16.0.202:3888           0.0.0.0:*                   LISTEN      102/java            

```

## 解决办法

解决随机端口问题需要在在hdfs-site.xml文件中显式添加rpc端口、http端口

```xml
	<property>
		<name>dfs.journalnode.rpc-address</name>
		<value>你的主机名HOSTNAME:8485</value>
	</property>
    <property>
		<name>dfs.journalnode.http-address</name>
		<value>你的主机名HOSTNAME:8480</value>
	</property>

```



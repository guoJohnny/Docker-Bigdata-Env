# Hadoop docker 搭建环境记录

# 搭建环境

- MacOSX Mojave 10.14
- docker desktop for Mac 
  - version 2.2.1.0
  - channel edge 
  - Engine 19.03.5
- docker 容器内操作系统镜像 centos7

# 构建 Hadoop 环境使用的命令

## 测试 WordCount 命令

```bash
# HDFS 上传文件
hadoop fs -put /home/root/data/myword.txt /data/wordcount
# 运行 Mapreduce
hadoop jar /usr/local/hadoop-2.8.3/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.3.jar wordcount /data/wordcount /output/wordcount
# 获取运行结果
hadoop fs -cat /output/wordcount/part-r-00000
# 移除运行结果
hadoop fs -rm -r hdfs://master:9000/output/wordcount
```

## 查看日志

```bash
tail -f /usr/local/hadoop-2.8.3/logs/yarn--resourcemanager-master.log 
```
# 搭建过程中出现的问题

## Retrying connect to server

```shell
15/04/17 10:59:57 INFO ipc.Client: Retrying connect to server: slave1/172.16.0.101:54310. Already tried 0 time(s).
15/04/17 10:59:58 INFO ipc.Client: Retrying connect to server: slave1/172.16.0.101:54310. Already tried 1 time(s).
15/04/17 10:59:59 INFO ipc.Client: Retrying connect to server: slave1/172.16.0.101:54310. Already tried 2 time(s).
15/04/17 11:00:00 INFO ipc.Client: Retrying connect to server: slave1/172.16.0.101:54310. Already tried 3 time(s).
```

节点不断尝试连接 datanode，且datanode的端口号是随机选择。

## 解决办法

解决随机端口问题需要在在yarn-site.xml文件中显式添加连接端口，如：9999

```xml
	<property>
		<name>yarn.nodemanager.hostname</name>
		<value>你的主机名HOSTNAME</value>
	</property>
    <property>
		<name>yarn.nodemanager.address</name>
		<value>你的主机名HOSTNAME:9999</value>
	</property>
    <property>
		<name>yarn.nodemanager.bind-host</name>
		<value>你的主机名HOSTNAME</value>
	</property>

```

解决连接不上 datanode 问题需要修改/etc/hosts文件中的中IPV6设置和localhost设置

参考连接：https://stackoverflow.com/questions/29692048/hadoop-ipc-client-retrying-connect-to-server-error/54278080

    Please check below list of configurations which should be performed at master and datanodes.

    Master: 1) Disable IP v6 2) Disable the firewall 3) Use Physical IP in hdfs-site.xml and mapered XML file instead of localhost. 4) In etc/hosts file, please comment all entries except master physical IP and datanode physical IP address. All IP starting from 127.*** and IP v6 entries should be commented.

    Datanode: 1) In etc/hosts file, please comment all entries except master physical IP and datanode physical IP address. All IP starting from 127.*** and IP v6 entries should be commented. 2) Use Physical IP in hdfs-site.xml and mapered XML file instead of localhost.


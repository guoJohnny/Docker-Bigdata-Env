# Spark docker 搭建环境记录

# 搭建环境

- MacOSX Mojave 10.14
- docker desktop for Mac 
  - version 2.2.1.0
  - channel edge 
  - Engine 19.03.5
- docker 容器内操作系统镜像 centos7
- Hadoop 2.8.3
- Zookeeper 3.4.12
- Spark 2.4.5
- Scala 2.12

# 构建 Spark HA 集群镜像主要命令
*（配置详见dockerfile及spark-entrypoint.sh）*

## 测试 Spark HA 命令

```bash
# 使用 Spark 自带调度工具
./spark-shell --master spark://master1:7077 --executor-memory 512M --total-executor-cores 2 --num-executors 2
# 使用 Yarn 作为调度管理工具
./bin/spark-shell --master yarn --deploy-mode client --executor-memory 512M --total-executor-cores 2 --num-executors 2
# 进入 shell 后执行 scala wordcount
sc.textFile("hdfs://master/data/wordcount/myword.txt").flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _).sortBy(_._2,false).take(10).foreach(println)
```

## 使用Spark submit 提交任务

```bash
# 集群模式，结果在yarn节点任务日志中
./bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode cluster \
    --driver-memory  1g\
    --executor-memory 512m \
    --executor-cores 2 \
    $SPARK_HOME/examples/jars/spark-examples_2.12-2.4.5.jar \
    10
# 客户端模式，结果显式在在控制台
./bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode client \
    --driver-memory 1g \
    --executor-memory 1g \
    --executor-cores 1 \
    $SPARK_HOME/examples/jars/spark-examples_2.12-2.4.5.jar \
    4
```

# 测试运行过程中出现的问题

## ApplicationAttemptNotFoundException

yarn 节点报错

```
20/04/03 02:23:54 ERROR ApplicationMaster: Uncaught exception: 
org.apache.hadoop.yarn.exceptions.ApplicationAttemptNotFoundException: Application attempt appattempt_1585880520954_0001_000002 doesn't exist in ApplicationMasterService cache.
	at org.apache.hadoop.yarn.server.resourcemanager.ApplicationMasterService.allocate(ApplicationMasterService.java:403)
```
通过下面两条命令查看 applicationattempt 状态

```bash
yarn applicationattempt -list application_1585960921894_0001
yarn applicationattempt -status appattempt_1585960921894_0001_000001
```

可以得知：

```
application Attempt Report : 
        ApplicationAttempt-Id : appattempt_1585960921894_0001_000001
        State : FAILED
        AMContainer : container_1585960921894_0001_01_000001
        Tracking-URL : http://master2:8088/cluster/app/application_1585960921894_0001
        RPC Port : -1
        AM Host : N/A
        Diagnostics : AM Container for appattempt_1585960921894_0001_000001 exited with  exitCode: -103
Failing this attempt.Diagnostics: Container [pid=931,containerID=container_1585960921894_0001_01_000001] is running beyond virtual memory limits. Current usage: 287.8 MB of 1 GB physical memory used; 2.2 GB of 2.1 GB virtual memory used. Killing container.
```
可以得知是yarn配置中虚拟内存溢出造成。

## 解决办法

需要修改yarn-site.xml的内存大小限制，使用默认的配置会出错。

```xml
<!--设置yarn内存分配最小值-->   
	<property>
		<name>yarn.scheduler.minimum-allocation-mb</name>
		<value>1024</value>
	</property>
	
	<property>
		<name>yarn.nodemanager.vmem-pmem-ratio</name>
		<value>3</value>
	</property>
	
```
## 运行时出现包重复上传警告

```bash
WARN yarn.Client: Neither spark.yarn.jars nor spark.yarn.archive is set, falling back to uploading libraries under SPARK_HOME.
INFO yarn.Client: Uploading resource file:/tmp/spark-91508860-fdda-4203-b733-e19625ef23a0/__spark_libs__4918922933506017904.zip -> hdfs://dbmtimehadoop/user/fuxin.zhao/.sparkStaging/application_1486451708427_0392/__spark_libs__4918922933506017904.zip
```
官网解决方案

	To make Spark runtime jars accessible from YARN side, you can specify spark.yarn.archive or spark.yarn.jars. 
	For details please refer to Spark Properties. If neither spark.yarn.archive nor spark.yarn.jars is specified, 
	Spark will create a zip file with all jars under $SPARK_HOME/jars and upload it to the distributed cache.

如果想要在yarn端（yarn的节点）访问spark的runtime jars，需要指定spark.yarn.archive 或者 spark.yarn.jars。如果都这两个参数都没有指定，spark就会把$SPARK_HOME/jars/所有的jar上传到分布式缓存中。这也是之前任务提交特别慢的原因。

## 解决办法

讲 Spark 的jar包打包上传HDFS

```bash
jar cv0f /usr/local/lib/spark-libs.jar -C $SPARK_HOME/jars/ .
hadoop fs -mkdir -p /tmp/spark/lib-jars/
hadoop fs -put  /usr/local/lib/spark-libs.jar hdfs://master/tmp/spark/lib-jars/
```

并在spark-default.conf中设置 spark.yarn.archive=hdfs:///some/path/spark-libs.jar
或者 spark.yarn.jars=hdfs:///some/path/*.jar
# docker 命令
    docker network create --subnet=172.15.0.0/16 hadoop

    docker build -t docker-centos:ssh .

    docker run -d --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup --name cluster-master -h cluster-master --net hadoop --ip 172.15.0.2 docker-centos:ssh /usr/sbin/init

    docker run -d --privileged -ti -v /sys/fs/cgroup:/sys/fs/cgroup --name cluster-slave1 -h cluster-slave1 --net hadoop --ip 172.15.0.3 docker-centos:ssh /usr/sbin/init

    docker exec -it cluster-master bash

# 进入 container 中执行

    vi hosts

    172.15.0.2      cluster-master
    172.15.0.3      cluster-slave1
    172.15.0.4      cluster-slave2
    172.15.0.5      cluster-slave3

    cat hosts >> /etc/hosts

# 进行 ssh 密钥交换

    ssh-copy-id  -f -i ~/.ssh/id_rsa.pub cluster-master
    ssh-copy-id  -f -i ~/.ssh/id_rsa.pub cluster-slave1

# commit 容器成为镜像

    docker commit -m 'add SSH netools' -a 'guojohnny <guojohnny@chihan.me>' cluster-master docker-centos:ssh-stable

    docker tag imageID guojohnny/docker-centos:ssh-stable

# 上传镜像

    docker login
    docker push guojohnny/docker-centos:ssh-stable

# 构建hadoop环境使用的命令

    echo "$(sed 's/localhost/slave1 localhost/g' /etc/hosts)" > /etc/hosts

    hadoop fs -put /home/root/data/myword.txt /data/wordcount

    hadoop jar /usr/local/hadoop-2.8.3/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.8.3.jar wordcount /data/wordcount /output/wordcount

    hadoop fs -cat /output/wordcount/part-r-00000

    hadoop fs -rm -r hdfs://master:9000/output/wordcount


    # echo "127.0.0.1		${ROLE} " >> /etc/hosts
    # echo "127.0.0.1		${HOSTNAME} localhost" >> /etc/hosts
    tail -f /usr/local/hadoop-2.8.3/logs/yarn--resourcemanager-master.log 

    sed -i '$d' /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
    echo "<property><name>yarn.nodemanager.hostname</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.address</name><value>${HOSTNAME}:0</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.bind-host</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "</configuration>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml

# 出现的错误

    2020-03-06 14:15:05,738 INFO org.apache.hadoop.ipc.Server: IPC Server Responder: starting
    2020-03-06 14:15:05,764 INFO org.apache.hadoop.ipc.Server: IPC Server listener on 8033: starting
    2020-03-06 14:15:05,858 INFO org.apache.hadoop.yarn.server.resourcemanager.ResourceTrackerService: NodeManager from node localhost(cmPort: 37519 httpPort: 8042) registered with capability: <memory:8192, vCores:8>, assigned nodeId localhost:37519
    2020-03-06 14:15:05,859 INFO org.apache.hadoop.yarn.server.resourcemanager.ResourceTrackerService: NodeManager from node localhost(cmPort: 42081 httpPort: 8042) registered with capability: <memory:8192, vCores:8>, assigned nodeId localhost:42081
    2020-03-06 14:15:05,873 INFO org.apache.hadoop.yarn.server.resourcemanager.rmnode.RMNodeImpl: localhost:37519 Node Transitioned from NEW to RUNNING
    2020-03-06 14:15:05,873 INFO org.apache.hadoop.yarn.server.resourcemanager.rmnode.RMNodeImpl: localhost:42081 Node Transitioned from NEW to RUNNING
    2020-03-06 14:15:05,895 INFO org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler: Added node localhost:37519 clusterResource: <memory:8192, vCores:8>
    2020-03-06 14:15:05,896 INFO org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler: Added node localhost:42081 clusterResource: <memory:16384, vCores:16>


	echo "<property><name>yarn.nodemanager.hostname</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.address</name><value>${HOSTNAME}:9999</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.bind-host</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "</configuration>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml

    错误原因 /etc/hosts 中IPV6设置和localhost设置  https://stackoverflow.com/questions/29692048/hadoop-ipc-client-retrying-connect-to-server-error/54278080

    This error is been handled now.

    Please check below list of configurations which should be performed at master and datanodes.

    Master: 1) Disable IP v6 2) Disable the firewall 3) Use Physical IP in hdfs-site.xml and mapered XML file instead of localhost. 4) In etc/hosts file, please comment all entries except master physical IP and datanode physical IP address. All IP starting from 127.*** and IP v6 entries should be commented.

    Datanode: 1) In etc/hosts file, please comment all entries except master physical IP and datanode physical IP address. All IP starting from 127.*** and IP v6 entries should be commented. 2) Use Physical IP in hdfs-site.xml and mapered XML file instead of localhost.


    cd /usr/local/hadoop-2.8.3/sbin	
	./hadoop-daemon.sh start journalnode	

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

    hdfs namenode -format
		./start-all.sh  


    hdfs namenode -bootstrapStandby	
		./hadoop-daemon.sh start namenode && ./yarn-daemon.sh start resourcemanager

    hdfs haadmin -getServiceState master1
    yarn rmadmin -getServiceState master1 

    
    #自动选举avtive

    hdfs haadmin -failover master1 master2

    hdfs --daemon stop namenode


# Hadoop-HA MacOSX docker问题描述
出现connect refused问题，端口为8485、8480、9000等端口连接不上的问题。主要集中于 JournalNode 节点。做Wordcount  例子的 Mapreduce 过程中也会出现这个问题。就是没有在配置中指定 Journalnode 端口，这样即使是在当前 netstat 命令得到在本地有开启相应端口，journalnode 也不允许外部节点访问，造成connect refuse 问题。

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

如果不显式配置，会出现 0.0.0.0:8485、  0.0.0.0:8480、 0.0.0.0:9999、

解决方法，手动在各个节点上添加 rpc 地址，http 地址配置。
    sed -i '$d' /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.hostname</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.address</name><value>${HOSTNAME}:9999</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "<property><name>yarn.nodemanager.bind-host</name><value>${HOSTNAME}</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	echo "</configuration>" >> /usr/local/hadoop-2.8.3/etc/hadoop/yarn-site.xml
	sed -i '$d' /usr/local/hadoop-2.8.3/etc/hadoop/hdfs-site.xml
	echo "<property><name>dfs.journalnode.rpc-address</name><value>${HOSTNAME}:8485</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/hdfs-site.xml
	echo "<property><name>dfs.journalnode.http-address</name><value>${HOSTNAME}:8480</value></property>" >> /usr/local/hadoop-2.8.3/etc/hadoop/hdfs-site.xml
	echo "</configuration>" >> /usr/local/hadoop-2.8.3/etc/hadoop/hdfs-site.xml

主从mysql进行同步操作

    show master status;

    #记录 主数据库 binary-log 的 文件名称 和 数据同步起始位置。

    CHANGE MASTER TO
        MASTER_HOST='mysql-master',
        MASTER_USER='root',
        MASTER_PASSWORD='root',
        MASTER_LOG_FILE='replicas-mysql-bin.000003',
        MASTER_LOG_POS=154;

    start slave

DROP TABLE IF EXISTS `course`;
CREATE TABLE `course` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL,
  `lesson_period` double(5,0) DEFAULT NULL,
  `score` double(10,0) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



./spark-shell --master spark://master1:7077 --executor-memory 512M --total-executor-cores 2 --num-executors 2

./bin/spark-shell --master yarn --deploy-mode client --executor-memory 512M --total-executor-cores 2 --num-executors 2

sc.textFile("hdfs://master/data/wordcount/myword.txt").flatMap(line => line.split(" ")).map(word => (word, 1)).reduceByKey(_ + _).sortBy(_._2,false).take(10).foreach(println)


./bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode cluster \
    --driver-memory  1g\
    --executor-memory 512m \
    --executor-cores 2 \
    $SPARK_HOME/examples/jars/spark-examples_2.12-2.4.5.jar \
    10

./bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode client \
    --driver-memory 1g \
    --executor-memory 1g \
    --executor-cores 1 \
    $SPARK_HOME/examples/jars/spark-examples_2.12-2.4.5.jar \
    4

yarn 节点报错
    20/04/03 02:23:54 ERROR ApplicationMaster: Uncaught exception: 
org.apache.hadoop.yarn.exceptions.ApplicationAttemptNotFoundException: Application attempt appattempt_1585880520954_0001_000002 doesn't exist in ApplicationMasterService cache.
	at org.apache.hadoop.yarn.server.resourcemanager.ApplicationMasterService.allocate(ApplicationMasterService.java:403)

yarn applicationattempt -list application_1585960921894_0001
yarn applicationattempt -status appattempt_1585960921894_0001_000001

pplication Attempt Report : 
        ApplicationAttempt-Id : appattempt_1585960921894_0001_000001
        State : FAILED
        AMContainer : container_1585960921894_0001_01_000001
        Tracking-URL : http://master2:8088/cluster/app/application_1585960921894_0001
        RPC Port : -1
        AM Host : N/A
        Diagnostics : AM Container for appattempt_1585960921894_0001_000001 exited with  exitCode: -103
Failing this attempt.Diagnostics: Container [pid=931,containerID=container_1585960921894_0001_01_000001] is running beyond virtual memory limits. Current usage: 287.8 MB of 1 GB physical memory used; 2.2 GB of 2.1 GB virtual memory used. Killing container.

需要修改yarn-site.xml和hdfs-site.xml的内存大小限制，使用默认的配置会出错。

    WARN yarn.Client: Neither spark.yarn.jars nor spark.yarn.archive is set, falling back to uploading libraries under SPARK_HOME.
    https://www.cnblogs.com/honeybee/p/6379599.html
    https://blog.csdn.net/Coder__CS/article/details/79301969

    hive –service hwi &
    hive --service hiveserver2 &
    启动metastore
        bin/hive --service metastore & 默认端口为9083

    启动hiveserver2
        nohup hiveserver2 &
        $HIVE_HOME/bin/hiveserver2 OR $HIVE_HOME/bin/hive --service hiveserver2
    
    To add the Spark dependency to Hive:
        Prior to Hive 2.2.0, link the spark-assembly jar to HIVE_HOME/lib.
        Since Hive 2.2.0, Hive on Spark runs with Spark 2.0.0 and above, which doesn't have an assembly jar.
        To run with YARN mode (either yarn-client or yarn-cluster), link the following jars to HIVE_HOME/lib.
            scala-library
            spark-core
            spark-network-common
        To run with LOCAL mode (for debugging only), link the following jars in addition to those above to HIVE_HOME/lib.
            chill-java  chill  jackson-module-paranamer  jackson-module-scala  jersey-container-servlet-core
            jersey-server  json4s-ast  kryo-shaded  minlog  scala-xml  spark-launcher
            spark-network-shuffle  spark-unsafe  xbean-asm5-shaded

    cp $SPARK_HOME/jars/scala-library-2.12.10.jar $HIVE_HOME/lib 
    cp $SPARK_HOME/jars/spark-core_2.12-2.4.5.jar $HIVE_HOME/lib 
    cp $SPARK_HOME/jars/spark-network-common_2.12-2.4.5.jar $HIVE_HOME/lib
    cp $SPARK_HOME/jars/spark-unsafe_2.12-2.4.5.jar $HIVE_HOME/lib

        <property>
        <name>spark.yarn.archive</name>
            <value>hdfs://master:8020/tmp/spark/lib-jars/spark-libs.jar</value>
        </property>

    <property>
    <name>hadoop.proxyuser.root.hosts</name>
    <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.root.groups</name>
        <value>*</value>
    </property>

    在hive中需要load hdfs中的文件，之后select 语句才能通过spark 进行查询
    load data inpath '/user/edureka_212418/hive_emp/emp_details.txt'  into table emp_hive;


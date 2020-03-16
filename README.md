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
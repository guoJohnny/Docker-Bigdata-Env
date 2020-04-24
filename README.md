# Docker Bigdata Environment

| 镜像名  | 说明 |
| ------------------------------------------------------------ | ----------------------------------------------------- |
| centos:ssh | 配置集群容器间SSH连接 |
| centos:jdk | JDK容器环境 |
| centos:hadoop | 基础 Hadoop 集群环境、一主二从节点环境 |
| centos:hadoop-ha | 二主三从、Zookeeper、高可用Hadoop集群环境 |
| centos:mysql | 主从mysql节点 |
| centos:zookeeper | Zookeeper 集群容器环境 |
| centos:spark | Spark HA 集群环境 |
| centos:hive | 搭建 Hive on Spark on Yarn集群环境 |
| centos:kafka | 以centos:zookeepe 镜像搭建 Kafka 集群容器环境 |

以上镜像通过文件夹下docker-compose.yml进行容器编排

---

| 依赖包  | 版本 |
| ------------------------------------------------------------ | ----------------------------------------------------- |
| Java | jdk-8u221-linux-x64.tar.gz |
| Hadoop | hadoop-2.8.3.tar.gz |
| Zookeeper | zookeeper-3.4.12.tar.gz |
| mysql-connector | mysql-connector-java-5.1.47.jar |
| Spark | spark-2.4.5-bin-without-hadoop-scala-2.12.tgz |
| Hive | apache-hive-3.1.2-bin.tar.gz |
| Scala | 2.12 |

---
 下表表示Hadoop HA 集群环境各对应关系
| 容器名 | 角色 | 对应IP地址 | 
| -------- | ------ | ------|
| master1 | NN（Active）、RM（Active） | 172.16.0.101 |
| master2 | NN（Standby）、RM（Standby） | 172.16.0.102 |
| slave1 | DN、JN、NM、ZK1 | 172.16.0.201 |
| slave2 | DN、JN、NM、ZK2 | 172.16.0.202 |
| slave3 | DN、JN、NM、ZK3 | 172.16.0.203 |

---
 下表表示Spark HA 集群环境各对应关系
| 容器名 | 角色 | 对应IP地址 | 
| -------- | ------ | ------|
| master1 | master（Active）、NN（Active）、RM（Active） | 172.16.0.101 |
| master2 | master（Standby）NN（Standby）、RM（Standby） | 172.16.0.102 |
| slave1 | Worker、DN、JN、NM、ZK1 | 172.16.0.201 |
| slave2 | Worker、DN、JN、NM、ZK2 | 172.16.0.202 |
| slave3 | Worker、DN、JN、NM、ZK3 | 172.16.0.203 |

---
 下表表示Hive on Spark 集群环境各对应关系
| 容器名 | 角色 | 对应IP地址 | 
| -------- | ------ | ------|
| master1 | hive、master（Active）、NN（Active）、RM（Active） | 172.16.0.101 |
| master2 | master（Standby）NN（Standby）、RM（Standby） | 172.16.0.102 |
| slave1 | DN、JN、NM、ZK1 | 172.16.0.201 |
| slave2 | DN、JN、NM、ZK2 | 172.16.0.202 |
| slave3 | DN、JN、NM、ZK3 | 172.16.0.203 |
| mysql | mysql | 172.16.0.1 |

---

# Hive on Spark docker 搭建环境记录

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
- Hive 3.1.2
- mysql-connector.jar 5.1.47

# 构建 Hive on Spark 集群镜像主要命令
*（配置详见dockerfile及hive-entrypoint.sh）*

解决Hive on Spark版本依赖不匹配问题，Hive 3.1.2 与 Spark 2.4.5 均使用官方编译版本

## 测试 Hive 命令

```bash
# 生成mysql元数据库，开启服务
cd $HIVE_HOME/bin
./schematool -dbType mysql -initSchema
./hive --service hiveserver2 &
# 启动hiveserver2
$HIVE_HOME/bin/hiveserver2 或者 $HIVE_HOME/bin/hive --service hiveserver2
```

# 搭建 Hive on Spark 过程中出现的问题

## Hive 找不到Spark Jar 包

在hive-site.xml 中配置 hive.execution.engine Hive 执行引擎为 Spark。

```xml
<property>
    <name>hive.execution.engine</name>
    <value>spark</value>
    <description>
      Expects one of [mr, tez, spark].
      Chooses execution engine. Options are: mr (Map reduce, default), tez, spark. While MR
      remains the default engine for historical reasons, it is itself a historical engine
      and is deprecated in Hive 2 line. It may be removed without further warning.
    </description>
  </property>
```
后运行 hive sql，在hive日志中出现java.lang.ClassNotFoundException报错。报错原因提示找不到：spark-core.jar、scala-library.jar、spark-network-common.jar中的类，如：org.apache.spark.sparkconf 类

通过官网的文档我们发现，配置Hive on Spark需要将Spark的依赖包添加进Hive：

```
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
```

执行该命令复制jar包

```bash
cp $SPARK_HOME/jars/scala-library-2.12.10.jar $HIVE_HOME/lib &&\
cp $SPARK_HOME/jars/spark-core_2.12-2.4.5.jar $HIVE_HOME/lib &&\
cp $SPARK_HOME/jars/spark-network-common_2.12-2.4.5.jar $HIVE_HOME/lib &&\
cp $SPARK_HOME/jars/spark-unsafe_2.12-2.4.5.jar $HIVE_HOME/lib
```

同时需要在hive-site.xml 中添加Spark on Yarn的依赖包路径，具体详见conf-hive/hive-site.xml配置项

```xml
        <property>
        <name>spark.yarn.archive</name>
            <value>hdfs://master:8020/tmp/spark/lib-jars/spark-libs.jar</value>
        </property>
```

## User: root is not allowed to impersonate hive

启动Hadoop前修改core-site.xml配置，解决 beeline 链接 hive2 出现 User: root is not allowed to impersonate hive 错误

```xml
    <property>
        <name>hadoop.proxyuser.root.hosts</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.root.groups</name>
        <value>*</value>
    </property>
```
## Hivesql shell 中 select 语句不通过 Yarn 进行运算

在hive shell sql中需要load hdfs中的文件，之后select 语句才能通过 Spark 进行查询

```    
load data inpath '/user/edureka_212418/hive_emp/emp_details.txt'  into table emp_hive;
```

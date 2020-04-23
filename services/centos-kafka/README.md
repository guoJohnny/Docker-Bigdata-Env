# Kafka docker 搭建环境记录

# 搭建环境

- MacOSX Mojave 10.14
- docker desktop for Mac 
  - version 2.2.1.0
  - channel edge 
  - Engine 19.03.5
- docker 容器内操作系统镜像 centos7
- Zookeeper 3.4.12
- kafka 2.12

# 测试 Kafka 命令

```bash
kafka-console-producer.sh --broker-list zk1:9092 -topic test
kafka-console-consumer.sh --bootstrap-server zk1:9092 -topic test --from-beginning
```

# 搭建过程中出现的问题

## Kafka 配置问题

## listener.security.protocol.map 
    先来看listener.security.protocol.map配置项，在上一章节中介绍过，它是配置监听者的安全协议的，比如PLAINTEXT、SSL、SASL_PLAINTEXT、SASL_SSL。因为它是以Key/Value的形式配置的，所以往往我们也使用该参数给Listener命名：
        listener.security.protocol.map=EXTERNAL_LISTENER_CLIENTS:SSL,INTERNAL_LISTENER_CLIENTS:PLAINTEXT,INTERNAL_LISTENER_BROKER:PLAINTEXT
    使用Key作为Listener的名称。就如上图所示，Internal Producer、External Producer、Internal Consumer、External Consumer和Broker通信以及Broker之间互相通信时都很有可能使用不同的Listener。这些不同的Listener有监听内网IP的，有监听外网IP的，还有不同安全协议的，所以使用Key来表示更加直观。当然这只是一种非官方的用法，Key本质上还是代表了安全协议，如果只有一个安全协议，多个Listener的话，那么这些Listener所谓的名称肯定都是相同的。

## listeners
    listeners就是主要用来定义Kafka Broker的Listener的配置项。
        listeners=EXTERNAL_LISTENER_CLIENTS://阿里云ECS外网IP:9092,INTERNAL_LISTENER_CLIENTS://阿里云ECS内网IP:9093,INTERNAL_LISTENER_BROKER://阿里云ECS内网IP:9094
    上面的配置表示，这个Broker定义了三个Listener，一个External Listener，用于External Producer和External Consumer连接使用。也许因为业务场景的关系，Internal Producer和Broker之间使用不同的安全协议进行连接，所以定义了两个不同协议的Internal Listener，分别用于Internal Producer和Broker之间连接使用。

    通过之前的章节，我们知道Kafka是由Zookeeper进行管理的，由Zookeeper负责Leader选举，Broker Rebalance等工作。所以External Producer和External Consumer其实是通过Zookeeper中提供的信息和Broker通信交互的。所以listeners中配置的信息都会发布到Zookeeper中，但是这样就会把Broker的所有Listener信息都暴露给了外部Clients，在安全上是存在隐患的，我们希望只把给外部Clients使用的Listener暴露出去，此时就需要用到下面这个配置项了。

## advertised.listeners
    advertised.listeners参数的作用就是将Broker的Listener信息发布到Zookeeper中，供Clients（Producer/Consumer）使用。如果配置了advertised.listeners，那么就不会将listeners配置的信息发布到Zookeeper中去了：
        advertised.listeners=EXTERNAL_LISTENER_CLIENTS://阿里云ECS外网IP:9092
    这里在Zookeeper中发布了供External Clients（Producer/Consumer）使用的ListenerEXTERNAL_LISTENER_CLIENTS。所以advertised.listeners配置项实现了只把给外部Clients使用的Listener暴露出去的需求。

## inter.broker.listener.name
    这个配置项从名称就可以看出它的作用了，就是指定一个listener.security.protocol.map配置项中配置的Key，或者说指定一个或一类Listener的名称，将它作为Internal Listener。这个Listener专门用于Kafka集群中Broker之间的通信：
        inter.broker.listener.name=INTERNAL_LISTENER_BROKER




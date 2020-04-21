# Hadoop docker 搭建环境记录

# 搭建环境

- MacOSX Mojave 10.14
- docker desktop for Mac 
  - version 2.2.1.0
  - channel edge 
  - Engine 19.03.5
- mysql镜像版本：5.7.17

# 构建 Mysql 主从节点使用的命令

## 检查主从库状态

进入mysql命令之后，检查主从库状态

```bash
show master status;
show slave status;
```
记录 主数据库 binary-log 的 文件名称 和 数据同步起始位置。

## 从库配置主库信息

```sql
CHANGE MASTER TO
        MASTER_HOST='mysql-master',
        MASTER_USER='root',
        MASTER_PASSWORD='root',
        MASTER_LOG_FILE='replicas-mysql-bin.000003',
        MASTER_LOG_POS=154;
```
## 重新启动 slave 服务

```bash
stop slave
start slave
```


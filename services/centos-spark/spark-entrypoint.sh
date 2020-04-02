main(){
    # 启动 Hadoop 配置
    cd /usr/bin
    ./hadoop-ha-entrypoint.sh
    
    cd $SPARK_HOME/sbin
    if [ ${HOSTNAME} == "master1" -a ${ROLE} == "master" ];then
        ./start-all.sh 
        hadoop fs -mkdir -p /data/wordcount
        hadoop fs -put /home/root/data/myword.txt /data/wordcount
    fi

    if [ ${HOSTNAME} == "master2" -a ${ROLE} == "master" ];then
        sleep 60       
        ./start-master.sh 
    fi
    
}

main
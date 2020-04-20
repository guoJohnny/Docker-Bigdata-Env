#!/bin/bash

configZookeeper(){
    chmod a+x $ZOOKEEPER_HOME/conf/config.sh
    echo "ZK_ID is ${ZK_ID}"
    echo "${ZK_ID}" >${ZOOKEEPER_HOME}/data/myid
    $ZOOKEEPER_HOME/bin/zkServer.sh start
}


main(){  
    configZookeeper
    sed -i "/broker.id=/c broker.id=${BROKER_ID}" $KAFKA_HOME/config/server.properties
    if [ -n  "$LISTENERS" ]; then 
        echo "listeners=${LISTENERS}" >> $KAFKA_HOME/config/server.properties
    fi
    if [ -n "$ADVERTISED_LISTENERS" ]; then
        echo "advertised.listeners=${ADVERTISED_LISTENERS}" >> $KAFKA_HOME/config/server.properties
    fi
    cd $KAFKA_HOME/bin && nohup ./kafka-server-start.sh ../config/server.properties &
}

main
#!/bin/bash

export CHISEL_HOME=$(cd `dirname $0`/..; pwd)

# Configures Java
setup_java() {
    JAVA=$(command -v java)
    if [[ -z "$JAVA" ]]; then
        if [[ -x "$JAVA_HOME/bin/java" ]]; then
            JAVA="$JAVA_HOME/bin/java"
        fi

        if [ ! -x "$JAVA" ]; then
            echo "Couldn't find java - set JAVA_HOME or add java to the path"
            exit 1
        fi
    fi

    # JVM parameters
    JVM_PARAMS="-Dlogging.config=$CHISEL_HOME/etc/logback.xml"
    JVM_PARAMS+=" -DLOG_LOCATION=$CHISEL_HOME/logs"
    JVM_PARAMS+=" -Dspring.config.location=$CHISEL_HOME/conf/application.properties"

    [[ -d /hive ]] && ACTIVE_PROFILE="hive" || ACTIVE_PROFILE="smi"

    JVM_PARAMS+=" -Dspring.profiles.active=${ACTIVE_PROFILE}"
}

# Application status
status() {
    if pgrep -f "java.*chisel" > /dev/null
    then
        echo "Chisel is running..."
    else
        echo "Chisel not running..."
    fi
}

# Starts the application
start() {
    if pgrep -f "java.*chisel" > /dev/null
    then
        echo "Chisel is already running..."
    else
        setup_java

        echo -n "Starting chisel..."

        exec ${JAVA} \
            -jar \
            ${JVM_PARAMS} \
            ${CHISEL_HOME}/lib/chisel-application*.jar &

        echo "started(`pgrep -f 'java.*chisel'`)"
    fi
}

# Stops the application
stop() {
    echo "Stopping chisel..."
    pkill -f 'java.*chisel'
}

if [[ ! -z $1 ]]; then
    case $1 in
        "start")
            start
            ;;
        "stop")
            stop
            ;;
        "restart")
            stop
            sleep 1
            start
            ;;
        "status")
            status
            ;;
        *)
            echo "Invalid argument provided: $1"
            exit 1
            ;;
    esac
else
    echo "No arguments provided (expected 'start', 'stop', or 'restart')!"
fi
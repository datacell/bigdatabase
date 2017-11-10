#!/bin/bash
# file: Service-start-cluster.sh
# Purpose: This script will start the entire Hadoop cluster

source /etc/profile

jps | grep -v Jps | awk '{print $1}' | xargs kill -9 > /dev/null

/bin/bash "/opt/hadoop/services/service-all-hadoop.sh"
/bin/bash "/opt/hadoop/services/service-all-hive.sh"
/bin/bash "/opt/hadoop/services/service-all-spark.sh"

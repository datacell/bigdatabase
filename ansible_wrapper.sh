#!/bin/sh

if [ $# -gt 0 ];
then
  if [ $1 = "-h" ] || [ $1 = "--help" ];
  then
    echo "Ansible wrapper is used to setup Hadoop clusters on AWS or Baremetal"
    echo "To be able to setup Hadoop along with machine prerequisites invoke ansible_wrapper as follows"
    echo "./ansible_wrapper.sh -b or ./ansible_wrapper.sh --baremetal with the following parameters in exact order"
    echo "<Target machine hostname>"
    echo "<Target machine ip>"
    echo "<Target machine ssh port (usually 22)>"
    echo "<Target machine ssh user (elevated user)>"
    echo "hadoop (To install APACHE HADOOP)"
    echo "For example ./ansible_wrapper.sh -b hadoop-server 10.44.121.3 22 root hadoop"
    echo "Note: ./ansible_wrapper.sh -b hadoop-server 10.44.121.3 22 without the hadoop parameter will install prerequisites to HADOOP"
    exit 0
  fi
  if [ $1 = "-b" ] || [ $1 = "--baremetal" ];
  then
    BAREMETAL=true
    if [ $# -gt 1 ];
    then
      if [ $2 ];
      then
        HOSTNAME=$2
      else
        echo "Please specify target Hostname"
        exit 1
      fi
      if [ $3 ];
      then
        IP=$3
      else
        echo "Please specify target IP"
        exit 1
      fi
      if [ $4 ];
      then
        SSHPORT=$4
      else
        echo "Using 22 as ssh default port"
        SSHPORT=22
      fi
      if [ $5 ];
      then
        SSHUSER=$5
      else
        echo "Please specify ssh user"
        exit 1
      fi
      exit 0
      if [ "$6" = "hadoop" ];
      then
        HADOOP=true
      else
        HADOOP=false
        #echo "Invalid parameter detected"
        #exit 1
      fi
    else
      echo "Baremetal specified but no arguments passed"
      exit 1
    fi
  fi
fi
if [ ! $BAREMETAL ];
then
  echo "----------------------Writing Inventory File for AWS.----------------------------"
  cp inventory/inventory_aws_template inventory/inventory_aws
  key=$AWS_PRIVATE_KEY_PATH
  if [ -z "$key" ];
  then
    echo "Please set path to private key.."
    exit $?
  fi
  key=$(echo ${key} | sed 's:/:\\\/:g')
  hosts=$(vagrant ssh-config | grep HostName | sed -e 's/\<HostName\>//g')
  each_host=$(echo $hosts | tr ' ' '\n')
  j=0
  num_hosts=$(echo "$each_host" | wc -w)
  echo "I detected $num_hosts hosts"
  for host in $each_host
  do
    if [ $num_hosts -eq 1 ];
    then
      echo "Replacing cedric-1.0.0-* with ${host} into ansible inventory.."
      sed -i "s/cedric-1.0.0-./${host}/" inventory/inventory_aws
    else
      j=$((j + 1))
      echo "Replacing cedric-1.0.0-${j} with ${host} into ansible inventory.."
      sed -i "s/cedric-1.0.0-${j}/${host}/g" inventory/inventory_aws
    fi
  done
  echo "Replacing AWS private key.."
  sed -i "s/si-bod.pem/${key}/g" inventory/inventory_aws
  if [ $? -ne 0 ];
  then
    exit_code=$?
    echo "failed while writing AWS Inventory File.."
    exit $exit_code
  fi
  echo "----------------------Successfully wrote Inventory File for AWS.-------------------"

  echo "----------------------Triggering the prerequisite playbook.----------------------------"
  ansible-playbook -i inventory/inventory_aws scripts/ansible-scripts/prerequisite/playbook.yml
  if [ $? -ne 0 ];
  then
    exit_code=$?
    echo "failed while deploying prerequisites.."
    exit $exit_code
  fi
  echo "----------------------Successfully completed prerequisites playbook.-------------------"

  echo "----------------------Triggering the machine-setup playbook.---------------------------"
  ansible-playbook -i inventory/inventory_aws scripts/ansible-scripts/machine-setup/playbook.yml
  if [ $? -ne 0 ];
  then
    exit_code=$?
    echo "failed while deploying machine-setup.."
    exit $exit_code
  fi
  echo "----------------------Successfully completed machine-setup playbook.-------------------"

  echo "----------------------Triggering the apache-hadoop playbook.---------------------------"
  ansible-playbook -i inventory/inventory_aws scripts/ansible-scripts/apache-hadoop/playbook.yml
  if [ $? -ne 0 ];
  then
    exit_code=$?
    echo "failed while deploying apache-hadoop.."
    exit $exit_code
  fi
  echo "----------------------Successfully completed apache-hadoop playbook.-------------------"

  echo "----------------------Triggering the webserver playbook.-------------------------------"
  ansible-playbook -i inventory/inventory_aws scripts/ansible-scripts/webserver/playbook.yml
  if [ $? -ne 0 ];
  then
    exit_code=$?
    echo "failed while deploying webserver.."
    exit $exit_code
  fi
  echo "----------------------Successfully completed webserver playbook.------------------------"

  echo "----------------------Triggering the start-cluster playbook.----------------------------"
  ansible-playbook -i inventory/inventory_aws scripts/ansible-scripts/apache-hadoop/startCluster.yml
  if [ $? -ne 0 ];
  then
    exit_code=$?
    echo "failed while starting hadoop cluster.."
    exit $exit_code
  fi
  echo "----------------------Successfully completed start-cluster playbook.--------------------"
else
  echo "----------------------Triggering Baremetal Deployment.--------------------"
  sed -i "s/cedric-100-1/${HOSTNAME}/" inventory/inventory
  sed -i "s/127.0.0.1/${IP}/" inventory/inventory
  sed -i "s/2222/${SSHPORT}/" inventory/inventory
  sed -i "s/ansible_ssh_private_key_file/ansible_ssh_user/" inventory/inventory
  sed -i "s/.vagrant\/machines\/cedric-100-1\/virtualbox\/private_key/${SSHUSER}/" inventory/inventory
  if [ $? -ne 0 ];
  then
    exit_code=$?
    echo "Failed while trying to set inventory. Please pass Hostname IP SSHPort SSHUser"
    exit $exit_code
  fi

  echo "----------------------Successfully wrote Inventory File for Baremetal-------------------"

  echo "----------------------Triggering the prerequisite playbook.----------------------------"
  ansible-playbook -i inventory/inventory scripts/ansible-scripts/prerequisite/playbook.yml --ask-pass
  if [ $? -ne 0 ];
  then
      exit_code=$?
      echo "failed while deploying prerequisites.."
      exit $exit_code
  fi
  echo "----------------------Successfully completed prerequisites playbook.-------------------"

  echo "----------------------Triggering the machine-setup playbook.---------------------------"
  ansible-playbook -i inventory/inventory scripts/ansible-scripts/machine-setup/playbook.yml --ask-pass
  if [ $? -ne 0 ];
  then
      exit_code=$?
      echo "failed while deploying machine-setup.."
      exit $exit_code
  fi
  echo "----------------------Successfully completed machine-setup playbook.-------------------"

  echo "----------------------Triggering the apache-hadoop playbook.---------------------------"
  if [ $HADOOP ];
  then
    ansible-playbook -i inventory/inventory scripts/ansible-scripts/apache-hadoop/playbook.yml --ask-pass
    if [ $? -ne 0 ];
    then
      exit_code=$?
      echo "failed while deploying apache-hadoop.."
      exit $exit_code
    fi
    echo "----------------------Successfully completed apache-hadoop playbook.-------------------"
  fi
  echo "----------------------Triggering the webserver playbook.-------------------------------"
  ansible-playbook -i inventory/inventory scripts/ansible-scripts/webserver/playbook.yml --ask-pass
  if [ $? -ne 0 ];
  then
      exit_code=$?
      echo "failed while deploying webserver.."
      exit $exit_code
  fi
  echo "----------------------Successfully completed webserver playbook.------------------------"

  echo "----------------------Triggering the start-cluster playbook.----------------------------"
  ansible-playbook -i inventory/inventory scripts/ansible-scripts/apache-hadoop/startCluster.yml --ask-pass
  if [ $? -ne 0 ];
  then
      exit_code=$?
      echo "failed while starting hadoop cluster.."
      exit $exit_code
  fi
  echo "----------------------Successfully completed start-cluster playbook.--------------------"

fi
echo "Successfully prepared the managed machine for SI deployment. Please proceed with SI context deployment."
exit 0

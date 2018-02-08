#!/bin/sh

# TODO: need to add one more play book command here in case this script is triggered for Ubuntu systems. 

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

echo "Successfully prepared the managed machine for SI deployment. Please proceed with SI context deployment."
exit 0


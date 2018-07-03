#!/bin/sh

echo "----------------------Writing Inventory File for AWS.----------------------------"
cp inventory/inventory_aws_template inventory/inventory_aws
key=$AWS_PRIVATE_KEY_PATH
if [ -z "$key" ];
then
  echo "Please set path to private key.."
  exit $?
fi
key=$(echo ${key} | sed 's:/:\\\/:g')
hosts=$(vagrant ssh-config | grep HostName)
each_host=$(echo $hosts | tr "HostName " "\n")
j=0
for host in $each_host
do
    j=$((j + 1))
    echo "Replacing cedric-1.0.0-${j} with ${host} into ansible inventory.."
    sed -i "s/cedric-1.0.0-${j}/${host}/g" inventory/inventory_aws
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

echo "Successfully prepared the managed machine for SI deployment. Please proceed with SI context deployment."
exit 0

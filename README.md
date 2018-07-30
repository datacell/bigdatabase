Vagrant for Hadoop, Spark and Hive on top of Postgresql
Python Anaconda2 5.0.1
=======================================================

# Introduction
--------------------------------------------------------------------------------
Vagrant project to spin up a virtual machine running cluster on top of
64 bit Ubuntu/Xenial:

* Hadoop 2.7.4
* Hive 1.2.2
* Spark 2.1.1
* Scala 2.11.6
* Postgresql 9.5 (for hive metastore)
* Anaconda2 5.0.1
* Node 8.9.0


The virtual machine will be running the following services:

* HDFS NameNode + DataNode
* YARN ResourceManager/NodeManager + JobHistoryServer + ProxyServer
* Hive metastore and server2
* Spark history server


# Getting Started
--------------------------------------------------------------------------------
VirtualBox deployment
--------------------------------------------------------------------------------
1. [Download and install VirtualBox 5.0.18](https://www.virtualbox.org/wiki/Downloads)
2. [Download and install Vagrant 2.1.1](http://www.vagrantup.com/downloads.html)
3. [Download and install Ansible 2.4.1.0](https://releases.ansible.com/ansible/)
4. [Install SSHPASS] (https://gist.github.com/arunoda/7790979)
5. Go to [releases](https://github.com/datacell/bigdatabase/releases) and
download and extract the latest source of this project
6. In your terminal change your directory into the project directory
(i.e. `cd bigdatabase`)
7. Run ```vagrant up``` to create the VM
8. Execute ```vagrant ssh``` to login to the VM
--------------------------------------------------------------------------------
AWS deployment
--------------------------------------------------------------------------------
1. [Download and install Vagrant 2.1.1](http://www.vagrantup.com/downloads.html)
2. [Download and install Ansible 2.4.1.0](https://releases.ansible.com/ansible/)
3. [Install SSHPASS] (https://gist.github.com/arunoda/7790979)
4. Go to [releases](https://github.com/datacell/bigdatabase/releases) and
download and extract the latest source of this project
5. In your terminal change your directory into the project directory
(i.e. `cd bigdatabase`)
6. Rename the Vagrantfile-aws to Vagrantfile
7. Run ```vagrant up``` to create the VM
8. Execute ```vagrant ssh cedric-1.0.0-1``` to login to the VM

--------------------------------------------------------------------------------
Bare metal deployment
--------------------------------------------------------------------------------
1. [Download and install Ansible 2.4.1.0](https://releases.ansible.com/ansible/)
2. [Install SSHPASS] (https://gist.github.com/arunoda/7790979)
3. Go to [releases](https://github.com/datacell/bigdatabase/releases) and
download and extract the latest source of this project
4. In your terminal change your directory into the project directory
(i.e. `cd bigdatabase`)
5. Run the ansible_wrapper.sh ```./ansible_wrapper.sh -b <Target machine hostname> <Target machine ip> <Target machine ssh port> <Target machine ssh user> hadoop```
6. Note: installing hadoop is optional, if the last parameter (6th) hadoop is not passed, the prerequisites to hadoop is installed
7. Note: Script will ask for sudo passwords multiple times during execution, please ensure provided user has elevated rights


# Web user interfaces
--------------------------------------------------------------------------------
Here are some useful links to navigate to various UI's:
--------------------------------------------------------------------------------
VirtualBox
--------------------------------------------------------------------------------

* YARN resource manager:  (http://localhost:8088)
* HDFS: (http://localhost:50070/dfshealth.html)
* Spark history server: (http://localhost:18080)
* Spark context UI (if a Spark context is running): (http://localhost:4040)
[Spark context server port is open from 4040 to 4044]

--------------------------------------------------------------------------------
AWS
--------------------------------------------------------------------------------
* YARN resource manager:  (http://<publicip>:8088)
* HDFS: (http://<publicip>:50070/dfshealth.html)
* Spark history server: (http://<publicip>:18080)
* Spark context UI (if a Spark context is running): (http://<publicip>:4040)
[Spark context server port is open from 4040 to 4044]

# Shared Folder (VirtualBox Only)
--------------------------------------------------------------------------------
Vagrant automatically mounts the folder containing the Vagrant file from the
host machine into the guest machine as `/vagrant` inside the guest.


# Managment of Vagrant VM
--------------------------------------------------------------------------------
To stop the VM and preserve all setup/data within the VM: -

```
vagrant halt
```

or

```
vagrant suspend
```

Issue a `vagrant up` command again to restart the VM from where you left off.


To completely **wipe** the VM so that `vagrant up` command gives you a fresh
machine: -

```
vagrant destroy
```

Then issue `vagrant up` command as usual.



# Starting / stoping services manually
--------------------------------------------------------------------------------

```
$ vagrant ssh
$ sudo su - hadoop

# Stop the services
$ jps | grep -v Jps | awk '{print $1}' | xargs kill -9

# Start the services
$ /bin/bash /opt/service-start-cluster.sh
```


# Credits

Thanks to Andrew Rothstein for the great work at
(https://github.com/andrewrothstein/ansible-anaconda)

Thanks to Martin Robson and xiaomei-data for great work at
(https://github.com/martinprobson/vagrant-hadoop-hive-spark)
(https://github.com/xiaomei-data/ansible-hadoop-spark)

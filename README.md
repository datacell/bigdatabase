Vagrant for Hadoop, Spark and Hive on top of Postgresql
Anaconda Python 2 v 5.0.1
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
1. [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. [Download and install Vagrant](http://www.vagrantup.com/downloads.html).
3. Go to [releases](https://github.com/datacell/bigdatabase/releases) and
download and extract the latest source of this project.
4. In your terminal change your directory into the project directory
(i.e. `cd bigdatabase`).
5. Run ```vagrant up``` to create the VM.
6. Execute ```vagrant ssh``` to login to the VM.


# Web user interfaces
--------------------------------------------------------------------------------
Here are some useful links to navigate to various UI's:

* YARN resource manager:  (http://localhost:8088)
* Job history:  (http://10.211.55.101:19888/jobhistory/)
* HDFS: (http://localhost:50070/dfshealth.html)
* Spark history server: (http://localhost:18080)
* Spark context UI (if a Spark context is running): (http://localhost:4040)
[Spark context server port is open from 4040 to 4044]


# Apache Zeppelin notebook server

Apache Zeppelin together with spark, md, file and JDBC interpreters is installed by default but not
started. To manually start the zeppelin daemon run: -

```
vagrant ssh
zeppelin-daemon.sh start
```

as `ubuntu` user from the command line.


Notebook server can then be accessed via `http://10.211.55.101:8080`.


# Shared Folder
--------------------------------------------------------------------------------
Vagrant automatically mounts the folder containing the Vagrant file from the
host machine into the guest machine as `/vagrant` inside the guest.



# Validating your virtual machine setup

To test out the virtual machine setup, and for examples of how to run
MapReduce, Hive and Spark, head on over to [VALIDATING.md](VALIDATING.md).


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

# Swapspace - Memory

Spark in particular needs quite a bit of memory to run - to work around this a `swapspace` daemon is also configured and
started that uses normal disk to dynamically allocate swapspace when memory is low.


# More advanced setup

If you'd like to learn more about working and optimizing Vagrant then
take a look at [ADVANCED.md](ADVANCED.md).

# For developers

The file [DEVELOP.md](DEVELOP.md) contains some tips for developers.

# Credits

Thanks to Alex Holmes for the great work at
(https://github.com/alexholmes/vagrant-hadoop-spark-hive)

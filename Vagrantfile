# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    ###Define the starting node number.
    i = 1
    #This will consume in computing last fraction of IP as well
    ip_last_fraction_address = 206

    plays = [ { :play => "prerequisite" },
              { :play => "machine-setup" },
              { :play => "apache-hadoop" },
              { :play => "webserver" } ]

    #Yarn scheduler                         8088
    #Spark History Server                   18088
    #Spark Master Web UI Port server        18080
    #Spark worker Web UI Port               18081
    #Spark Job ports                        4040..4044
    #Unassigned ports for external feature  5800..5803
    ports = [ 5800, 5801, 5802, 5803, 50070, 8088, 18088, 18080, 18081, 4040, 4041, 4042, 4044 ]

    ### Define which linux box need to be used###
    #config.vm.box = "centos/7"
    config.vm.box = "ubuntu/xenial64"

    #Define port forwarding
    ports.each do |port|
      config.vm.network :forwarded_port, guest: port, host: port
    end

    #Define box information
    config.vm.box_download_insecure = true
    config.vm.define  "node#{i}" do |node|
        node.vm.hostname="node#{i}"
        node.vm.network :private_network, ip: "205.28.128.#{ip_last_fraction_address}"

        node.vm.provider "virtualbox" do |v|
          v.name =  "node#{i}"
          v.memory = 8192
          v.cpus = 2
        end
    end


    #config.vm.synced_folder ".", "/vagrant", create: true, type: "nfs"
    #Check if Ububtu then install Python. Ubuntu boxes are not pre-configured
    # with Python.
    if config.vm.box.include? 'ubuntu'
        config.vm.provision :ansible do |preps|
            preps.limit = "all"
            #preps.verbose = "v"
            preps.playbook = "scripts/ansible-scripts/prerequisite/python.yml"
            preps.inventory_path = "inventory/inventory"
       end
    end


    # Execute all plays using ansible script to setup single node Hadoop Cluster
    plays.each do |name|
      config.vm.provision :ansible do |ansible|
        # Disable default limit to connect to all the machines
        ansible.limit = "all"
        #ansible.verbose = "v"
        ansible.playbook = "scripts/ansible-scripts/#{name[:play]}/playbook.yml"
        ansible.inventory_path = "inventory/inventory"
      end
    end

    #Start the Hadoop service for every time vagrant command executed.
    config.vm.provision :ansible, run: 'always' do |startService|
        #Disable default limit to connect to all the machines
        startService.limit = "all"
        #startService.verbose = "v"
        startService.playbook = "scripts/ansible-scripts/apache-hadoop/startCluster.yml"
        startService.inventory_path = "inventory/inventory"
    end
end

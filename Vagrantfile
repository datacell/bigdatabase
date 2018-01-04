# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    ###Define the starting node number.
    NumVm = 3

    #This will consume in computing last fraction of IP as well
    ip_last_fraction_address = 210

    #Define root disk drive size in GB. Please check any limitations at https://github.com/sprotheroe/vagrant-disksize
    root_disk_size = 150

    #Define machine name initials. This will compromise in hostname as well
    server_initials = "barty"

    #Current version
    current_version = "2-0-0"

    plays = [ { :play => "prerequisite" },
              { :play => "machine-setup" },
              { :play => "apache-hadoop" },
              { :play => "webserver" }]


    #Yarn scheduler                         8088
    #Map Reduce Job History Server          19888
    #Spark History Server                   18088
    #Spark Master Web UI Port server        18080
    #Spark worker Web UI Port               18081
    #Spark Job ports                        4040..4044
    #Unassigned ports for external feature  5800..5803
    ports1 = [ 5800, 5801, 5802, 5803 ]
    ports2 = [ 8088, 18088 ]
    #ports = [ 5800, 5801, 5802, 5803, 50070, 8088, 18088, 18080, 18081, 4040, 4041, 4042, 4044 ]

    ### Define which linux box need to be used###
    #config.vm.box = "shareinsights/albus"
    config.vm.box = "ubuntu/xenial64"

    #Define box information
    config.vm.box_download_insecure = true
    config.disksize.size = "#{root_disk_size}GB"
    config.landrush.enabled = true
    config.landrush.tld = "#{server_initials}.dev"

    #Create number of Vms and associte with its values
    (1..NumVm).each do |j|
        adder = ip_last_fraction_address + j - 1
        ssh_adder = 2225 + j

        config.vm.define  "#{server_initials}#{j}-#{current_version}.#{config.landrush.tld}" do |node|
            node.vm.hostname="#{server_initials}#{j}-#{current_version}.#{config.landrush.tld}"
            node.vm.network :private_network, ip: "205.28.128.#{adder}"
            node.vm.network :forwarded_port, guest: 22, host: ssh_adder, id: "ssh"

            node.vm.provider "virtualbox" do |v|
                v.name =  "#{server_initials}#{j}-#{current_version}.#{config.landrush.tld}"
                v.memory = 3072
                v.cpus = 2
            end #End of provider

            if j == 1
                #Define port forwarding
                ports1.each do |port|
                    node.vm.network :forwarded_port, guest: port, host: port
                end #End of port
            end #End of if

            #Run ansible on last host once all host machine are up and running.
            #If we do if on config level then it will run playbook for all host
            #one by one. That will involve repetation of playbook.
            if j == NumVm
                #Check if Ububtu then install Python. Ubuntu boxes are not pre-configured
                # with Python.
                if config.vm.box.include? 'ubuntu'
                    node.vm.provision :ansible do |preps|
                        preps.limit = "all"
                        #preps.verbose = "v"
                        preps.playbook = "scripts/ansible-scripts/prerequisite/python.yml"
                        preps.inventory_path = "inventory/inventory"
                   end #End of ansible
                end #End of if

                plays.each do |name|
                    node.vm.provision :ansible do |ansible|
                        # Disable default limit to connect to all the machines
                        ansible.limit = "all"
                        #ansible.verbose = "v"
                        ansible.playbook = "scripts/ansible-scripts/#{name[:play]}/playbook.yml"
                        ansible.inventory_path = "inventory/inventory"
                    end #End of ansible
                end #End of loop

                #Start the Hadoop service for every time vagrant command executed.
                node.vm.provision :ansible, run: 'always' do |startService|
                    #Disable default limit to connect to all the machines
                    startService.limit = "all"
                    #startService.verbose = "v"
                    startService.playbook = "scripts/ansible-scripts/apache-hadoop/startCluster.yml"
                    startService.inventory_path = "inventory/inventory"
                end #End of services

          end #End of if
        end #End of define
    end #End of loop for all servers

end #End of vagrant

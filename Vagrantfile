# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require the AWS provider plugin
require 'vagrant-aws'
# Require the host shell plugin
require 'vagrant-host-shell'

Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

DUMMY_BOX_URL = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
NAME_VAGRANT = "dummy.box" #"vagrant-aws-ansible-bod"

# NOTE: The following variables must be set according your aws configuration:
# export AWS_ACCESS_KEY='????????????????????'
# export AWS_SECRET_KEY='????????????????????????????????????????'
# export AWS_PRIVATE_KEY_PATH='~/.ssh/vagrant.pem'
# export AWS_DEFAULT_REGION='us-east-1'
# export AWS_EC2_KEY_NAME='vagrant'
# export AWS_SECURITY_GROUP_NAME='vagrant'

# AMI Data
HOSTS = {
  'cedric-1.0.0-1' => {
    :amazon_image  => 'ami-061e5979',     #BOD-Cedric-Node-1
    :amazon_availability_zone => 'a',     #a,b,c,d,e
    :shh_username  => 'centos',
    :instance_type => 'r4.large',
    :device_name => '/dev/sda1',
    :device_size_gb  => 50,
    :device_delete_on_termination => true,
    :device_type => 'gp2'
  },
  'cedric-1.0.0-2' => {
    :amazon_image  => 'ami-bdb9fcc2',     #BOD-Cedric-Node-2
    :amazon_availability_zone => 'a',     #a,b,c,d,e
    :shh_username  => 'centos',
    :instance_type => 'r4.large',
    :device_name => '/dev/sda1',
    :device_size_gb  => 50,
    :device_delete_on_termination => true,
    :device_type => 'gp2'
  },
  'cedric-1.0.0-3' => {
    :amazon_image  => 'ami-54c7822b',     #BOD-Cedric-Node-3
    :amazon_availability_zone => 'a',     #a,b,c,d,e
    :shh_username  => 'centos',
    :instance_type => 'r4.large',
    :device_name => '/dev/sda1',
    :device_size_gb  => 50,
    :device_delete_on_termination => true,
    :device_type => 'gp2'
  }
  }

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
# Create and configure the AWS instance(s)

  HOSTS.each do | name, info |

    # Use dummy AWS box
    config.vm.box = NAME_VAGRANT
    ##--config.vm.box = "ubuntu/xenial64"
    config.vm.box_download_insecure = true
    config.vm.box_url = DUMMY_BOX_URL
    #config.vm.provider = 'aws'

    availability_zone = ENV['AWS_DEFAULT_REGION'] + info[:amazon_availability_zone]
    config.ssh.insert_key = false
    config.vm.synced_folder ".", "/vagrant", disabled: true
    #config.vm.synced_folder ".", "/vagrant"

    config.vm.define name do |vm_name|
      vm_name.vm.provider :aws do |aws, override|
        aws.access_key_id        = ENV['AWS_ACCESS_KEY']
        aws.secret_access_key    = ENV['AWS_SECRET_KEY']
        aws.region               = ENV['AWS_DEFAULT_REGION']
        aws.availability_zone    = availability_zone
        aws.keypair_name         = ENV['AWS_EC2_KEY_NAME']
        aws.security_groups      = ENV['AWS_SECURITY_GROUP_NAME']
        aws.subnet_id            = ENV['AWS_SUBNET_ID_VPC']
        aws.ami                  = info[:amazon_image]
        aws.instance_type        = info[:instance_type]
        aws.block_device_mapping = [{
          'DeviceName'              => info[:device_name],
          'Ebs.VolumeSize'          => info[:device_size_gb],
          'Ebs.DeleteOnTermination' => info[:device_delete_on_termination],
          'Ebs.VolumeType'          => info[:device_type]
        }]
        aws.tags = {
          'Name'        => name,
        }

        # SSH:
        override.ssh.username = info[:shh_username]
        override.ssh.private_key_path = ENV['AWS_PRIVATE_KEY_PATH']
        override.vm.provision :shell do |sh|
               sh.inline = "sudo hostnamectl set-hostname #{name}.shareinsights.com
                            sudo hostnamectl set-hostname #{name}.shareinsights.com --pretty
                            sudo hostnamectl set-hostname #{name}.shareinsights.com --static
                            sudo hostnamectl set-hostname #{name}.shareinsights.com --transient"
        end
      end #End of AWS
      #  Execute Ansible Shell script
      vm_name.trigger.after [:up, :halt] do |trigger|
          if name == "cedric-1.0.0-3" # Invoke after 3rd node is deployed
             trigger.info = "All instances up, setting host mapping"
             trigger.run = {path: "./ansible_wrapper.sh"}
          end
      end
    end #End of config name
  end #End of Hosts
end #End of Vagrant configure

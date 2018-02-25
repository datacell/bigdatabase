#!/bin/bash

# make sure that the path of .pem file is passed as first argument. 
if [ $# == 0 ]; then
  echo "Please pass the path of .pem file as first argument."
  exit 1
else
  if [ -e $1 ];
  then 
	  echo "File \"$(basename $1)\" exists, moving ahead ...."
  else
	  echo "File \"$(basename $1)\" does not exist, please specify the correct path."
    exit 1
  fi
fi

# TODO: Remove the host entry from hosts file. 

sudo mkdir /opt/workspace
sudo chown centos:centos /opt/workspace
cd /opt/workspace
git clone https://sibuild:SIBuild%40007@github.com/datacell/shareinsights.git

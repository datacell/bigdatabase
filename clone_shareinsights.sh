#!/bin/bash

# TODO: Remove the host entry from hosts file. 

sudo mkdir /opt/workspace
sudo chown centos:centos /opt/workspace
cd /opt/workspace
git clone https://sibuild:SIBuild%40007@github.com/datacell/shareinsights.git

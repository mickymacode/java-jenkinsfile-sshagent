#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo service docker start
sudo usermod -aG docker ec2-user

 # install docker-compose 
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

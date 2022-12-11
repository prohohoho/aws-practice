#!/bin/bash 
  sudo ufw enable  
  sudo ufw allow from 203.173.222.36 to any port 22
  sudo ufw allow from 203.173.222.36 to any port 80
  sudo apt update
  sudo apt install -y apt-transport-https
  wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -sc) stable" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt update
  sudo apt install -y docker-ce
  sudo docker run -it -d -p 80:80 --name=ngjohnx --health-cmd ='curl --fail --insecure http://localhost:80 || exit 1' --health-interval=30s --health-start-period=3m nginx
  sudo apt update
  sudo apt install -y moreutils  
  sudo apt install -y plocate
  sudo apt install software-properties-common
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt update
  sudo apt install -y python3.8
  sudo apt install git  
  sudo apt install -y python3-flask
 
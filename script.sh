  #!/bin/bash
  sudo ufw enable
  sudo ufw allow 22/tcp
  sudo ufw allow ssh
  sudo apt update
  sudo apt install -y apt-transport-https
  wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -sc) stable" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt update
  sudo apt install -y docker-ce
  docker run --name mynginx1 -p 80:80 -d nginx  
  sudo docker stats --no-stream mynginx1 >> test.log
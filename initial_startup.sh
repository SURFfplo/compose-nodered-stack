#!/bin/bash

#############################################################################
# COLOURS AND MARKUP
#############################################################################

red='\033[0;31m'            # Red
green='\033[0;49;92m'       # Green
yellow='\033[0;49;93m'      # Yellow
white='\033[1;37m'          # White
grey='\033[1;49;30m'        # Grey
nc='\033[0m'                # No color

clear

echo -e "${yellow}
# Test if machine is running in swarm if not start it 
#############################################################################${nc}"
if docker node ls > /dev/null 2>&1; then
  echo already running in swarm mode 
else
  docker swarm init 
  echo docker was a standalone node now running in swarm 
fi
echo -e "${green}Done....${nc}"



echo -e "${yellow}
# Test if network is running in overlay if not start it
#############################################################################${nc}"
docker network ls|grep appnet > /dev/null || docker network create --driver overlay appnet
sleep 5
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Check if node-red containter is available and build if needed
#############################################################################${nc}"
DIRECTORY='image-nodered'
if [ ! -d ../"$DIRECTORY" ]; then
  echo " https://github.com/SURFfplo/"$DIRECTORY".git ../"$DIRECTORY" "
  git clone https://github.com/SURFfplo/"$DIRECTORY".git ../"$DIRECTORY"
fi
docker-compose build nodered 
echo -e "${green}Done....${nc}"

echo -e "${yellow}
# Create config for mysql container 
#############################################################################${nc}"
docker config create nodered_conf config/settings.js
echo -e "${green}Done....${nc}"


echo -e "${yellow}
# Create folder structure for psql container
#############################################################################${nc}"
mkdir .data
mkdir .data/nodered
echo -e "${green}Done....${nc}"

echo -e "${yellow}
# Create the service
#############################################################################${nc}"
docker stack deploy -c docker-compose.yml nodered
echo -e "${green}Done....${nc}"



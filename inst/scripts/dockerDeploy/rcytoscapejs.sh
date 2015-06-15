!/bin/bash

echo "Pulling new version"
sudo docker pull cannin/rcytoscapejs

echo "Stopping new container"
sudo docker stop rcytoscapejs
sudo docker rm rcytoscapejs

echo "Starting new container"
sudo docker run --restart always --name rcytoscapejs -d -p 3840:3838 -t cannin/rcytoscapejs shiny-server

clear
# docker rmi $(docker images -f "dangling=true" -q)
# docker image list

#Clear Ports
fePort=4002
bePort=3002
lsof -i ":$fePort" | grep node | awk '{print $2}' | while read pid; do kill -9 $pid; done
lsof -i ":$bePort" | grep node | awk '{print $2}' | while read pid; do kill -9 $pid; done

#Stop Docker Compose
docker-compose down

#Clear Old Images
docker images | grep iproject
docker rmi iproject-web
docker rmi iproject-api

#check if web/dist
if [ ! -d "web/dist" ]
then
  echo "web/dist not found."
  cd web
  echo "creating ... "
  ng build
  echo "web/dist created."
  cd ..

else
  echo "web/dist found."
fi

# Drop old database
export PGPASSWORD='5okharoth'
psql --username=bheng \
-h iproject.cjbvry0ekzyh.us-east-1.rds.amazonaws.com \
-d postgres \
-c "DROP DATABASE iproject;"

# Create new database
export PGPASSWORD='5okharoth'
psql --username=bheng \
-h iproject.cjbvry0ekzyh.us-east-1.rds.amazonaws.com \
-d postgres \
-c "CREATE DATABASE iproject;"

#Build
time docker-compose build --no-cache | tee docker-build.log

#Start
docker-compose up

#Open a mwebbrowser
# python -mwebbrowser http://localhost:8080

# Tag + Push Docker Images
# ------------------
docker tag iproject-api bheng/iproject-api:latest
docker tag iproject-web bheng/iproject-web:latest
docker push bheng/iproject-web:latest
docker push bheng/iproject-api:latest
docker images | grep iproject
#

# clean out docker bad data
# ------------------
# docker container prune --force
# docker image prune --force
# docker network prune --force
# docker volume prune --force

# docker rmi $(docker images -f "dangling=true" -q)

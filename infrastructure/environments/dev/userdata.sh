#!/bin/bash
set -e
exec > /var/log/userdata.log 2>&1

echo "=== Starting PetClinic setup ==="

apt-get update -y
apt-get install -y git curl

# Install Java 17
apt-get install -y openjdk-17-jdk

java -version

# Clone the application
cd /opt
git clone https://github.com/suresh-osi/petclinic.git
cd /opt/petclinic

chmod +x mvnw

# Set HOME so Maven wrapper can locate .m2 cache
export HOME=/root

echo "=== Building PetClinic ==="
./mvnw package -DskipTests

echo "=== Starting PetClinic ==="
nohup java -jar /opt/petclinic/target/*.jar \
  --server.port=8080 \
  > /opt/petclinic/app.log 2>&1 &

echo "PetClinic started with PID $!"

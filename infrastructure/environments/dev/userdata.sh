#!/bin/bash

yum update -y

yum install git -y

amazon-linux-extras install java-openjdk17 -y

cd /opt

git clone https://github.com/suresh-osi/petclinic.git

cd petclinic

chmod +x mvnw

./mvnw package

nohup java -jar target/*.jar > app.log 2>&1 &

#!/bin/bash

cd ../infrastructure/environments/dev

terraform init

terraform apply -auto-approve

#!/bin/bash

export CODEDEPLOY=/opt/wordpress-codedeploy

# Target
cd $CODEDEPLOY
export PROJECT=$(ls -1 target-* | sed -e 's/target-//g')
export PROJECT_WITHOUT_WWW=$(echo $PROJECT | sed 's/www\.//g')

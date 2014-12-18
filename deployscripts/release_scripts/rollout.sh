#!/bin/sh


echo "Starting rollout of tar....."
echo "sh  deployscripts/release_scripts/deploy.sh $1 $2"
sh  deployscripts/release_scripts/deploy.sh $1 $2


#!/bin/bash

checkparam=${@: -1}

cd /data/var/installs

rm -f deployscripts.tar.gz
wget http://192.168.33.71/deploy_scripts/deployscripts.tar.gz
tar zxvf deployscripts.tar.gz

cd deployscripts
copytarpath=/data/var/installs/deploytar

if [ $checkparam == yes ];then

        latesttar=$(ls -tr $copytarpath | tail -1)
        echo "Deploy tar -$latesttar";
        echo "sh relmain.sh "$@" $latesttar"
       sh relmain.sh "$@" $latesttar
else
        echo "sh relmain.sh "$@" "
       sh relmain.sh "$@"
fi

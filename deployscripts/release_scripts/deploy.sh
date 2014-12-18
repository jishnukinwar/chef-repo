#!/bin/bash

deploy_date=$(date '+%F %H:%M:%S')
deploy_tar_name=$1
relfolder=$2

deploy_files=$(tar tzf $1)
if [ $? -ne 0 ];then
        echo "Corrupted TAR. Exiting Deploy.sh"
#        exit 
fi

echo "**************** Create RollBack package *************"
dir=`pwd`
files=`tar tzf $1 |tr "[\n]" "[ ]"  | sed  -e 's/^/\//g'`
echo $files
rb=`echo $1 | cut -d "." -f1`
rb=`echo $rb'_rollback.tar.gz'`
echo $rb

tar zvcf $rb $files
 
echo "**************** RollBack package Created *************"


echo "**************** Deploying package  *************"
echo "tar zxf $1 -C /"
tar zxvf $1 -C /
tomcatpath=$(echo $files | awk -F"/webapps/" '{print $1}')
contextname=$(echo $files | awk -F"/webapps/" '{print $2}')
echo "contextname- $tomcatpath, $contextname"

echo "cd $tomcatpath/webapps/"
cd $tomcatpath/webapps/


reldbhost=192.168.33.71
reldb=REL
mysqlCmd="mysql -uread -preader -h$reldbhost --database=$reldb -B -N"

cmd="select livecontext_nm from enviornment_details where project_nm='DAM' and vertical_nm='Common Platform' "
livecontext_nm=$($mysqlCmd  -e "$cmd")
if [ -z $livecontext_nm ];then
        echo "Empty $livecontext_nm  Exiting Deploy.sh"
        exit 
fi

#echo "ln -s $contextname $livecontext_nm"
#ln -s $contextname $livecontext_nm
echo "cp $contextname $livecontext_nm"
cp -R $contextname $livecontext_nm


echo "**************** Creating Release Notes *************"
cd $relfolder
echo "sh deployscripts/release_scripts/releasenotes.sh $1"
sh deployscripts/release_scripts/releasenotes.sh $1
echo "*******************Deployed Successful**********"



#!/bin/sh

ACTFLAG=$1
SVR=$2
TAR_ID=$3
WORKFLAG=$4
RESTOMFLAG=$5
RESAPACHEFLAG=$6
USER=$7
JOBNAME=$8
PROJECT_NM=$9

deployworkfolder=/data/var/installs
deployscripts=$deployworkfolder/deployscripts
globaltarpath=$deployworkfolder/deploytar

reldbhost=192.168.33.71
reldb=REL
reluser=reluser
relpassword="rel@567"
mysqlconn="mysql -u$reluser -p$relpassword -h$reldbhost $reldb -B -N"

DT=`date '+%F %T'`
export TMOUT=0

 cmd="select livepath from enviornment_details where PROJECT_NM='$PROJECT_NM'"
 livecontext_nm=$($mysqlconn  -e "$cmd")
 cmd="select apachepath from enviornment_details where PROJECT_NM='$PROJECT_NM'"
 apachepath=$($mysqlconn  -e "$cmd")
 cmd="select Appport from enviornment_details where PROJECT_NM='$PROJECT_NM'"
 tomcatport=$($mysqlconn  -e "$cmd")
 tomcatpath=$(echo $livecontext_nm  |awk -F'/webapps' '{print $1}')


#cd $deployworkfolder
sh release_scripts/validate.sh $SVR $TAR_ID  $PROJECT_NM
validateresult=$?
if [[ $validateresult !=  0 ]]; then
	echo "Failed in Validation step.Please check all parameters & start again.Exiting."
	exit 2
fi

if [ "$ACTFLAG" == "R" ];then
{
	echo "Rolling out $TAR_ID on $SVR"
	cmd="ls -lrth|grep $(date "+%d%b%Y")|tail -1|awk '{print \$9}'"
	echo $cmd
	relfolder=$(ls -lrth|grep $(date "+%d%b%Y")|tail -1|awk '{print $9}')
	echo $relfolder

	if [ -n "$relfolder" ]
	then
		echo "Release folder exists"
		#folder=$deployworkfolder/$relfolder
		folder=$deployworkfolder/$relfolder"_1"
		echo $folder
	else
		echo "Release folder doesnt exists"
		folder=$deployworkfolder/$(date "+%d%b%Y")
		echo $folder
	fi

	echo "mkdir $folder"
	mkdir $folder

echo "mv  $deployscripts   $folder"
mv  $deployscripts   $folder

echo "mv $globaltarpath/$TAR_ID $folder"
mv $globaltarpath/$TAR_ID $folder
	echo "cd $folder"
	cd $folder


RB_1=`echo $TAR_ID | cut -d "." -f1`
echo $RB_1

RB_TAR=`echo $folder/$RB_1'_rollback.tar.gz'`
echo $RB_TAR

	if [ $RESAPACHEFLAG = 'Y' ];then
		sh deployscripts/release_scripts/webrun.sh stop_apache 
	fi
	if [ $RESTOMFLAG = 'Y' ];then
		sh deployscripts/release_scripts/webrun.sh stop_tomcat $tomcatpath $tomcatport 
	fi
	if [ $WORKFLAG = 'Y'  ] ; then
		tar -tzf $TAR_ID|grep webapps
		if [ $? -ne 0 ];then
			WORK=`tar -tzf $TAR_ID|awk -F'data/' '{print $2}'|awk -F'/' '{print $1}'|sort|uniq`
		else 
			WORK=`tar -tzf  $TAR_ID |awk -F'webapps/' '{print $2}'|awk -F'/' '{print $1}'|sort|uniq`
	fi
		echo "removing $livecontext_nm/work/Catalina/localhost/$WORK/org/apache/jsp/*"
		rm -fr $livecontext_nm/work/Catalina/localhost/$WORK/org/apache/jsp/*
	fi
	echo "sh deployscripts/release_scripts/rollout.sh $TAR_ID $folder"
	sh deployscripts/release_scripts/rollout.sh $TAR_ID $folder
	sh deployscripts/release_scripts/webrun.sh start_apache   
	sh deployscripts/release_scripts/webrun.sh start_tomcat $tomcatpath $tomcatport 
	deploytype=R
	cmd="insert into release_txn (dep_date,dep_server,deploytar,rollbacktar,userid,workflg,resflg,deploytype) values ('$DT','$SVR','$TAR_ID','$RB_TAR','$r_USERID','$WORKFLAG','$RESTOMFLAG','$deploytype');"
	echo $cmd
	$mysqlconn -e "$cmd"
}
else
{
###  rollback
	deploytype=RB
	cmd="select rollbacktar from release_txn where deploytar='$TAR_ID' order by dep_date desc limit 1"
	echo $cmd
	RB_TAR=$($mysqlconn -e "$cmd")
	if [ -z $RB_TAR ];then
		echo "rollback tar not present. Exit Script"
		exit 2
	fi
	folder=`echo $RB_TAR |awk -F'/CCR' '{print $1}'`
	echo "$RB_TAR |awk -F'$folder' '{print $2}'"
	exit 0 
	RB_TAR2=`echo $RB_TAR |awk -F'$folder' '{print $2}'`
#	RB_TAR2=`echo $RB_TAR |awk -F'$deployworkfolder' '{print $2}'|awk -F'/' '{print $2}'|sed -e 's/ //g'`
	echo "RB_TAR2-$RB_TAR2"
	exit 0
	cd $folder;
	echo "rolling back $RB_TAR2 on $SVR"
	echo $folder $RB_TAR2

	#sh deployscripts/release_scripts/rollback.sh $RB_TAR2
	cmd="insert into release_txn (det_date,server,tarid,rollbackid,userid,workflg,resflg,type) values ('$DT','$SVR','$TAR_ID','$RB_TAR1','$r_USERID','$WORKFLAG','$RESTOMFLAG','$deploytype');"
	echo $cmd
	$mysqlconn -e "$cmd"
}
fi

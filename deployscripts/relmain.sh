#!/bin/bash

#################	Global variables Starts TimesInternet Deployment		####################	
PARAM=$@
PARAMCT=$#

deployworkfolder=/data/var/installs
deployscripts=$deployworkfolder/deployscripts
globaltarpath=$deployworkfolder/deploytar
tarpath_node=$globaltarpath
mkdir -p  $deployscripts/logs
LOGFILE=$deployscripts/logs/deploy.txt
touch $LOGFILE
TMPDIR=/tmp/release
mkdir -p $TMPDIR


MYSQL_SRV=192.168.33.71
MYSQL_CONN='mysql -uread -preader -h '$MYSQL_SRV' -D REL -e'
MAIL_ID=`$MYSQL_CONN "select mailid from escalation where userid='$USER';"|tail -1`
ESCL="kapila.narang@timesinternet.in,$MAIL_ID"
#ESCL="24x7grp@timesinternet.in,$MAIL_ID"
#################	Global variables Ends		####################	


##################	Routines Start	###############################

get_tarid()
{
	TAR_ID=$TAR
	if [ -e $tarpath_node/$TAR_ID ];then
		echo "Tar present in Deplpy folder-$tarpath_node/$TAR_ID"
	else
		echo "Tar -$TAR_ID not present in  $tarpath_node/$TAR_ID. Exiting release.sh"
		exit 0
	fi
}
check_param_count()
{
if [ $PARAMCT -lt 9 ] ;
then
        echo "ERROR: Usage:sudo relmain.sh R/B server(s) CCR_tar_id Y/N Y/N Y/N DeployUser JenkinsJobName(rollout/rollback server_list_comma_seperated ccr_upload_id, remove_work_folder,restart_server,Shutdown Server,deployuser,Jenkins Job Name)" >>$LOGFILE
        echo "ERROR: Usage:sudo relmain.sh R/B server(s) CCR_tar_id Y/N Y/N Y/N DeployUser JenkinsJobName(rollout/rollback server_list_comma_seperated ccr_upload_id, remove_work_folder,restart_server,Shutdown Server,deployuser,Jenkins Job Name)" 
        exit 2
else
  echo "1)Parameters correct<br>" 
  echo "1)Parameters correct" >>$LOGFILE
fi
}
get_param()
{
	ACTFLAG=`echo $PARAM | awk '{print $1}'| tr [a-z] [A-Z]|sed 's/ //g'`
	SVR=`echo $PARAM | awk '{print $2}'|sed 's/ //g'`
	WORKFLAG=`echo $PARAM | awk '{print $3}'|sed 's/ //g'| tr [a-z] [A-Z]`
	RESTOMFLAG=`echo $PARAM | awk '{print $4}'|sed 's/ //g'| tr [a-z] [A-Z]`
	RESAPACHEFLAG=`echo $PARAM | awk '{print $5}'|sed 's/ //g'| tr [a-z] [A-Z]`
	USER=`echo $PARAM | awk '{print $6}'|sed 's/ //g'| tr [a-z] [A-Z]`
	JOBNAME=`echo $PARAM | awk '{print $7}'|sed 's/ //g'| tr [a-z] [A-Z]`
	PROJECT_NM=`echo $PARAM | awk '{print $8}'|sed 's/ //g'| tr [a-z] [A-Z]`
	value=`echo $PARAM | awk '{print $9}'|sed 's/ //g'`
        if [ $value == yes ]; then
                TAR=`echo $PARAM | awk '{print $10}'|sed 's/ //g'`
        else
                TAR=`echo $PARAM | awk '{print $9}'|sed 's/ //g'`
        fi

	echo "2)ACTFLAG=$ACTFLAG, SVR=$SVR, TAR_ID=$TAR, WORKFLAG=$WORKFLAG, RESTOMFLAG=$RESTOMFLAG" RESAPACHEFLAG=$RESAPACHEFLAG USER=$USER JOBNAME=$JOBNAME PROJECT_NM=$PROJECT_NM>>$LOGFILE
	echo "2)ACTFLAG=$ACTFLAG, SVR=$SVR, TAR_ID=$TAR, WORKFLAG=$WORKFLAG, RESTOMFLAG=$RESTOMFLAG RESAPACHEFLAG=$RESAPACHEFLAG USER=$USER JOBNAME=$JOBNAME PROJECT_NM=$PROJECT_NM<br>"
}

check_param()
{
if [ $ACTFLAG != 'R' -a $ACTFLAG != 'RB' ] ; then
	echo "Use R or RB in first parameter rollout/rollback"
	echo "Use R or RB in first parameter rollout/rollback"  >>$LOGFILE
	exit 2
elif [ -z `echo $SVR|grep '192.169.|192.168.' ` ] ; then
        echo "Use 192.169 series server in list"  >>$LOGFILE
        echo "Use 192.169,192.168 series server in list<br>" 
#        exit 2
elif [ -z `echo $TAR_ID|grep CCR ` ] ; then
        echo "Use valid tar id"
        exit 2
elif [ `echo $WORKFLAG ` != 'Y' -a `echo $WORKFLAG ` != 'N' ] ; then
	echo "Use Y or N in Forth parameter remove_work_folder"
        exit 2
elif [ `echo $RESTOMFLAG ` != 'Y' -a `echo $RESTOMFLAG ` != 'N' ] ; then
        echo "Use Y or N in Fifth parameter restart_server"
        exit 2
elif [ `echo $RESAPACHEFLAG ` != 'Y' -a `echo $RESAPACHEFLAG ` != 'N' ] ; then
        echo "Use Y or N in Sixth parameter Shutdown server"
        exit 2
fi

if [ -z `echo $SVR|grep '192.168' ` ] ; then
	LOCATION='MUM'
elif [ -z `echo $SVR|grep '192.169' ` ] ; then
	LOCATION='CHN'
echo "Data Center LOCATION=$LOCATION"
fi
}

rollout_code()
{
	echo "Rolling out $TAR_ID on $SVR" 
	sh release_scripts/release.sh  $ACTFLAG $SVR $TAR_ID $WORKFLAG $RESTOMFLAG $RESAPACHEFLAG $USER $JOBNAME $PROJECT_NM
	if [ $ACTFLAG = 'R' ];then
		echo "mail -s "RELEASE: Tar $TAR_ID deployed on $SVR by $USER, verify and enable" $ESCL </dev/null"
	else
		echo "mail -s "RELEASE: Tar $TAR_ID rolled back on $SVR by $USER, verify and enable" $ESCL </dev/null"
	fi
}
##################	Routines End	###############################

###################		MAIN Logic	###########################3
check_param_count
get_param
get_tarid
check_param
	#echo "rollout_code $SVR $TAR_ID $WORKFLAG $RESTOMFLAG  $JOB_NAME"
	rollout_code $SVR $TAR_ID $WORKFLAG $RESTOMFLAG  $JOB_NAME
###################		MAIN Logic	###########################3

#!/bin/bash


r_svr=$1
r_TAR_ID=$2
project_nm=$3

Apptype="Application"
reldbhost=192.168.33.71
reldb=REL
reluser=reluser
relpassword="rel@567"
mysqlconn="mysql -u$reluser -p$relpassword -h$reldbhost $reldb -B -N"
 cmd="select livepath from enviornment_details where project_nm='$project_nm'"
 livecontext_nm=$($mysqlconn  -e "$cmd")

systarpath="/data/var/installs/deploytar"
echo `pwd`
echo "tar -tf $systarpath/$r_TAR_ID"
tarpath=$(tar -tf $systarpath/$r_TAR_ID )
if [ -z $tarpath ];then
	echo "Tar path empty $tarpath"
	exit 2
fi

check_tarlivepath()
{
tarpath_match=$(tar -tf $systarpath/$r_TAR_ID | grep "$livecontext_nm")
if [ -z $tarpath_match ];then 
	echo "Livepath in Artifact & Database dont match-$tarpath,$livecontext_nm"
	exit 2
fi
livecontext_nm=/$livecontext_nm
if [ ! -d $livecontext_nm ]; then
	echo "Livepath folder doesnt exist on the machine -$livecontext_nm"
	exit 2
fi
}

check_ipaddress()
{
    sysip=`sh release_scripts/ip.sh`
    if [ $r_svr != $sysip ];then
    	echo "IPAddress don't match with machine ip. Exiting now check $r_svr != $sysip"
	exit 2
    fi	
}
check_livepath()
{
echo "$livecontext_nm" | grep -q "tomcat"  
if [ $?  == 1 ]; then 
	echo "tomcat path doesnt exist in livepath into DB-$livecontext_nm"
	exit 2
fi

}

check_ccrid_state()
{
cmd="basename $1  |awk -F'CCR_' '{split(\$2,a,\".\");print a[1]}' |  sed -e 's/[a-zA-Z]//g' | awk -F\"-\" '{print \$1}'"
ccr_id=$(basename $1  |awk -F'CCR_' '{split($2,a,".");print a[1]}' |  sed -e 's/[a-zA-Z]//g' | awk -F"-" '{print $1}')
echo $ccr_id

valid=true
 
if [ -n "$ccr_id" ]
then
	for i in `echo $ccr_id|tr [','] [' ']`
	do
		url="http://192.168.27.100/crf_details_preview2.php?id="$ccr_id"&VAL=status"
		id=`curl -s $url`
		echo $id 
		if [ ! -n "$id" ]
		then
			echo "invalid ccrid $i ,pls mention correct ccrid in tarname"
			valid=false
			exit 2
		fi
	done
else
	echo "pls mention ccrid in tarname"
	valid=false
	exit 2
fi
 
if [ $valid == false ]
then
 mail -s"wrong deployment for tar $1" Kapila.Narang@timesinternet.in </dev/null
exit 2
fi
}
check_project_iplist()
{
   svrs_list=`curl -q http://SCMAPI:timesscm420@192.168.27.100/SCM_API/GET_IP.php?PROJECT=$project_nm`
   echo $svrs_list| grep $r_svr 
    validateresult=$?
	if [[ $validateresult !=  0 ]]; then
		echo "IP Address passed to script dont match with IP address in database.Please check.Exiting"
#		exit 2
	fi


}
check_artifact_haswar()
{
	warval=$(tar -tzf $systarpath/$r_TAR_ID | grep '.war')
	if [ -z $warval ]; then
		echo "Passed artifact doesnt have war.Please check.Exiting $warval"
		exit 2
	fi
	echo "tar ztf $systarpath/$r_TAR_ID  | grep -v '.war'"
	otherfilesInArtifact=$(tar ztf $systarpath/$r_TAR_ID  | grep -v '.war')
	if [ ! -n $otherfilesInArtifact ]; then
		echo "Artifact has other files also except only WAR.So far only war deplyment allowed.Please check.Exiting"
		echo "Files are -$otherfilesInArtifact"
		exit 2
	fi
}

check_ipaddress
check_livepath
check_tarlivepath
check_project_iplist
check_artifact_haswar

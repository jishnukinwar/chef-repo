#!/bin/bash

deployworkfolder=/data/var/installs
deployscripts=$deployworkfolder/deployscripts/release_scripts
globaltarpath=$deployworkfolder/deploytar

ccr_id=$(echo $1|awk -F'CCR' '{split($2,a,".");print a[1]}')
dir=`pwd`
mkdir -p $deployworkfolder/ReleaseNotes/
relnote=$deployworkfolder/ReleaseNotes/relnote_$ccr_id"_"`date '+%F:%H:%M:%S'`

echo "Release Folder"$dir >> $relnote

count=0
#for i in `ls *.gz|grep -v rollback`
#do
#	count=$[$count+1]
#	echo $count CCR= $i >> $relnote
#	echo '' >> $relnote
#	
#	echo Changed Files name-- >> $relnote
#	tar tzf $i >> $relnote
#	echo '' >> $relnote
#	
#done
echo CCR= $1 >> $relnote
echo '' >> $relnote
echo Changed Files name-- >> $relnote
tar tzf $1 >> $relnote
echo '' >> $relnote

	echo Deployed Servers list-- >> $relnote
	echo '' >> $relnote
        #echo 'Serverdeployed='`cat servers.txt|wc -l` >> $relnote
	echo '' >> $relnote

#	echo 'No of CCR gone LIVE='$count >> $relnote

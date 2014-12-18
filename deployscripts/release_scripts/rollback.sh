#!/bin/bash

d=`pwd`
echo "dir-$d"
exit

reldbhost=192.168.33.71
reldb=REL
reluser=reluser
relpassword="rel@567"
mysqlconn="mysql -u$reluser -p$relpassword -h$reldbhost $reldb -B -N"

rollback_date=$(date '+%F %H:%M:%S')
$cmd="select rollbacktar from release_txn where deploytar='$1' ;"
echo $cmd
rollbacktar_nm=$($mysqlconn  -e "$cmd")
rollback_files=$(tar tzf $1)
deploy_dir=$(pwd)

echo "inside rollback $d"
tar -C / -zxvf $1

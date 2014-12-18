#!/bin/bash
#
# tomcat     This shell script takes care of starting and stopping Tomcat
#
#
# Short-Description: start and stop tomcat & apache
PARAM=$@
PARAMCT=$#

TOMCAT_HOME=$2
PORT=$3
TOMCAT_USER=root
#echo "TOMCAT_HOME-$TOMCAT_HOME,PORT=$PORT"

SHUTDOWN_WAIT=45

check_param_count()
{
echo $PARAM |grep  "tomcat"
if [ $? -ne 1 ];then
	if [ $PARAMCT -lt 3 ];then
		echo "please give 2 more arguments for tomcat in order TOMCAT PATH & PORT"
		exit 0
	fi
fi
}
check_param_count

apache_pid(){
	PGREP="/usr/bin/pgrep"
	HTTPD="httpd"
	echo `$PGREP ${HTTPD}`
}
start_apache(){
	pid=$(apache_pid)
    if [ -n "$pid" ]
    then
        echo "Apache is already running (pid: $pid)"
    else
        echo "Starting Apache..."
	/etc/init.d/httpd start 
	pid_count=`ps ax | grep -v grep | grep -c httpd`
	if [ $pid_count -ge 0 ];then 
		echo "Successful Restart of Apache."
	fi 
    fi
    return 0
}
stop_apache(){
    pid=$(apache_pid)
    if [ -n "$pid" ]; then
        echo "Stoping Apache....."
	/etc/init.d/httpd stop
    fi
	pid_count=`ps ax | grep -v grep | grep -c httpd`
	if [ $pid_count -le 0 ];then 
		echo "Successful Shutdown of Apache."
	fi 
    return 0
}
tomcat_pid() {
        echo `netstat -ntpl | grep java | grep $PORT | awk '{print $7}' | awk -F"/" '{print $1}' `
}
start_tomcat() {
	if [ -z $PORT ] && [ -z $TOMCAT_HOME ];then
	#if [ -n "$PORT" ] && [ -n "$TOMCAT_HOME" ];then
		echo "Please enter the PORT no. && Tomcat path"
		exit 2
	fi
    pid=$(tomcat_pid)
    if [ -n "$pid" ]
    then
        echo "Tomcat is already running (pid: $pid)"
    else
	echo "Starting tomcat"
	TOMCAT_HOME=/$TOMCAT_HOME
        echo "sh $TOMCAT_HOME/bin/startup.sh"
        sh $TOMCAT_HOME/bin/startup.sh
    fi
    return 0
}
stop_tomcat() {
    pid=$(tomcat_pid)
    if [ -n "$pid" ]
    then
	TOMCAT_HOME=/$TOMCAT_HOME
        echo "Stoping Tomcat"
       echo " /bin/su - -c "cd $TOMCAT_HOME/bin && $TOMCAT_HOME/bin/shutdown.sh""
        /bin/su - -c "cd $TOMCAT_HOME/bin && $TOMCAT_HOME/bin/shutdown.sh"

    let kwait=$SHUTDOWN_WAIT
    count=0
    count_by=5
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
        echo "Waiting for processes to exit. Timeout before we kill the pid: ${count}/${kwait}"
        sleep $count_by
        let count=$count+$count_by;
    done

    if [ $count -gt $kwait ]; then
        echo "Killing processes which didn't stop after $SHUTDOWN_WAIT seconds"
        kill -9 $pid
    fi
    else
        echo "Tomcat is not running"
    fi

    return 0
}
#case $3 in
case $1 in
    start_tomcat)
        start_tomcat
        ;;
    stop_tomcat)
        stop_tomcat
        ;;
    restart_tomcat)
        stop_tomcat
        start_tomcat
        ;;
    start_apache)
        start_apache
        ;;
    stop_apache)
        stop_apache
        ;;
    restart_apache)
        stop_apache
        start_apache
        ;;
    apache_pid)
	apache_pid
	;;	
    tomcat_status)
	if [ -z "$PORT" ];then
		echo "Please enter the PORT no."
		exit 0
	fi
        pid=$(tomcat_pid)
        if [ -n "$pid" ];  then
           echo "Tomcat is running with pid: $pid & port no. $PORT"
        else
           echo "Tomcat is not running for Port $PORT"
        fi
        ;;
    apache_status)
       pid=$(apache_pid)
        if [ -n "$pid" ]
        then
           echo "Apache is running with pid: $pid"
        else
           echo "Apache is not running"
        fi
esac
exit 0

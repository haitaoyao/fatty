#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-06-29.18:18:22
# 
##################################################################
current_dir=$(cd $(dirname $0);pwd) 
. $current_dir/script_env.sh 
read_fatty_config()
{
	cat $FATTY_CONFIG_HOME/fatty.conf|grep -v "#"|awk -F "$1=" '{print $2}'	
}

fatty_log()
{
	while getopts "l:m:" OPT
	do
		case $OPT in
			l)
				LOG_LEVEL=$OPTARG
				;;
			m)
				LOG_MSG=$OPTARG
				;;
			:)
				LOG_LEVEL="INFO"
				;;
		esac
	done
	if [ -z "$LOG_LEVEL" ]
	then
		LOG_LEVEL=INFO
	fi
	date_string=$(date +%Y-%m-%d-%H:%M:%S)
	printf  "FATTY_LOG $LOG_LEVEL $date_string $LOG_MSG\n"
	printf  "FATTY_LOG $LOG_LEVEL $date_string $LOG_MSG\n" >> $FATTY_LOG_DIR/fatty.$(date +%Y%m%d).log
}

#generate the app version of the app file
get_timestamp()
{
	echo $(date +%Y%m%d%H%M%S)
}


# get the deploy center list
# list all the file name in $FATTY_CONFIG_HOME with '.dc.conf' as the suffix
get_deploy_center_list()
{
	ls $FATTY_CONFIG_HOME|grep -e '.deploy.conf'|cut -d '.' -f 1 
}

get_file_md5()
{
	if [ -z "$1" -o ! -f "$1" ]
	then 
		echo "no file ERROR"
		exit 1
	fi
	echo $(md5sum $1|awk '{print $1}')
}

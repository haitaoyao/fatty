#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-06-29.13:55:05
# used to query the application packages history
# 
##################################################################
current_dir=$(cd $(dirname $0);pwd)

#set the environment variables
. $current_dir/script_env.sh
. $current_dir/common.sh

# print the help information
print_help()
{
	echo
	echo "This is used to query the application archiver"
	echo "Usage: $0 -f app_file -n app_name -d query_day -v app_version -m"
	echo
	#printf "\t-f\t the app file to query\n"
	printf "\t-n\t the app name to query\n"
	printf "\t-v\t the app version to query\n"
	printf "\t-m\t show the query result with the information\n"
	printf "\t-d\t query the result of the specific day, format: %s, for example, to query the files deployed at 2011-07-01, use -d 20110701 as the parameter\n" '%Y%m%d'
	echo
}
if [ -z "$1" ]
then
	print_help
	exit 1
fi
while getopts ":n:d:mv:" OPT
do
	case $OPT in
		#f)
		#	app_file=$OPTARG
		#	;;
		n)
			app_name=$OPTARG
			;;
		m)
			show_message=1
			;;
		d)
			query_day=$OPTARG
			;;
		#m)
		#	query_month=$OPTARG
		#	;;
		v)
			app_version=$OPTARG
			;;
		?)
			print_help
			exit 1
			;;
		:)
			print_help
			exit 1
			;;
	esac
done

if [ -z "$app_name" ] 
then
	echo "app name should not be null"
	print_help
	exit 1
fi

#if [ -z "$app_version" -a  ]
#then
#OB	echo "No arguments!"
#	print_help
#	exit 1
#fi

local_storage_location=$(read_fatty_config "storage_location")/$app_name

if [ ! -d "$local_storage_location" ]
then
	echo "app name: $app_name invalid!"
	echo
	print_help
	exit 1
fi

find_files()
{
	for app_file in $(find $local_storage_location -maxdepth 2 -type f -name "$1")
	do
		has_query_result="1"
		printf "\tapp_name: %s, argument:%s\n" $app_name $1
		printf "\t\tpath:%s\n" $app_file
		printf "\t\tmd5: $(md5sum $app_file|awk '{print $1}')\n"
		printf "\t\t$(stat $app_file |grep Modify)\n"
		printf "\t\tsize:$(du -sh $app_file |awk '{print $1}')\n"
		if [ ! -z "$show_message" -a -f "$app_file".info ]
		then
			printf "\t\tInfo:\n"
			cat $app_file.info
		fi
		echo
	done
	if [ -z "$has_query_result" ]
	then
		echo "No result, app name: $1, argument: $1"
	fi
}

if [ ! -z "$app_version" ]
then
	find_files ${app_name}___${app_version}___$query_day*.tar.gz
else
	find_files ${app_name}___*___${query_day}*.tar.gz
fi

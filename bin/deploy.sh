#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-06-29.13:55:41
#
# used to deploy the package into deploy centers
#   
##################################################################
current_dir=$(cd $(dirname $0);pwd)

#set the environment variables
. $current_dir/script_env.sh
. $current_dir/common.sh

#print the help information
print_help()
{
	echo
	echo "This is used to deploy the application packages to deploy centers"
	echo "Usage: $0 -n app_name -v app_version -d deploycenter_list"
	printf "\t-n\t the app name to deploy\n"
	printf "\t-v\t the app version to deploy\n"
	printf "\t-d\t the deploy center list to push. ALL means deploy the package into all the deploy centers.\n"
	echo
}

if [ -z "$1" ]
then
	print_help
	exit 1
fi

while getopts ":f:d:n:v:" OPT
do
	case $OPT in
		f)
			app_file=$OPTARG
			;;
		n)
			app_name=$OPTARG
			;;
		d)
			deploycenter_list=$OPTARG
			;;
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

# check the arguments
if [ -z "$app_name" -o -z "$app_version" ]
then
	echo "app_name and app_version should not be empty"
	print_help
	exit 1
fi
if [ -z "$deploycenter_list" ]
then
	echo "no deploycenter specified"
	exit 1
fi

# split the deploycenter list 
get_deploycenters()
{
	if [ x"$deploycenter_list" = x"ALL" ]
	then
		echo $(get_deploy_center_list)
	else
		echo $deploycenter_list |awk -F',' '{for (x=1;x<=NF; x++){print $x}}'
	fi
}

for deploycenter in $(get_deploycenters)
do
	if [ ! -f "$FATTY_CONFIG_HOME/$deploycenter.deploy.conf" ]
	then
		fatty_log -m  "no config file found in $FATTY_CONFIG_HOME for deploycenter:$deploycenter"
		exit 1
	fi
done

# get the local file
get_local_app_file()
{
	
	local_storage_location=$(read_fatty_config "storage_location")	
	local_app_file=$(find $local_storage_location/$app_name -maxdepth 2 -type f -name "${app_name}___${app_version}___*.tar.gz" )
	if [ "$(echo $loca_app_file|wc -l)" -gt 1 ]
	then
		fatty_log -l ERROR -m "more than 1 packages found for $app_name, version: $app_version, files: \n $local_app_file"
		exit 1
	fi
	if [ -z "$local_app_file" -o  "$(echo $local_app_file | wc -l )" -ne 1 -o ! -f "$local_app_file" ]
	then
		fatty_log -l ERROR -m "NO package found for app_name: $app_name , app_version: $app_version "
		exit 1
	fi
	app_file_timestamp=$(echo $local_app_file|awk -F '___' '{print $3}' |cut -d '.' -f 1)
	if [ -z "$app_file_timestamp" -o $(echo "$app_file_timestamp"|awk '{print length ($0)}' ) -ne 14 ]
	then
		fatty_log -l ERROR -m "can't get file timestamp, file: $local_app_file, timestamp: $app_file_timestamp"
		exit 1
	fi
	now_file_md5=$(get_file_md5 $local_app_file)
	if [ ! -f "${local_app_file}.md5" ]
	then
		fatty_log -l WARN -m "no md5 file for app file: $local_app_file"
		return 0
	fi
	recorded_file_md5=$(cat ${local_app_file}.md5)
	if [ x"$now_file_md5" != x"$recorded_file_md5" ]
	then
		fatty_log -l ERROR -m "md5 not match, file: $app_file, now md5: $now_file_md5, expected md5: $recorded_file_md5"
		exit 1
	fi
}


get_local_app_file

if [ "$?" -ne 0 ]
then
	exit 1
fi

if [ ! -f $local_app_file ]
then
	fatty_log -m  "local app file: $local_app_file not found, check the app_name: $app_name, app_version: $app_version you specified"
	exit 1
else
	fatty_log -m  "\n\t\t$local_app_file will be deployed\n"
fi


for deploycenter in $(get_deploycenters)
do
	fatty_log -m  "install $local_app_file into $deploycenter"
	if [ -f $FATTY_CONFIG_HOME/$deploycenter.deploy.install.sh ] 
	then
		fatty_log -m  "use custom script $FATTY_CONFIG_HOME/$deploycenter.deploy.install.sh"
		bash $FATTY_CONFIG_HOME/$deploycenter.deploy.install.sh  ${app_name}___${app_version}___${app_file_timestamp}.tar.gz $local_app_file $deploycenter $app_name
		if [ "$?" -ne 0 ]
		then
			fatty_log -l ERROR -m  "failed to install $local_app_file into $deploycenter "
			exit 1
		fi
	else
		bash $current_dir/deploy.install.sh ${app_name}___${app_version}___${app_file_timestamp}.tar.gz $local_app_file $deploycenter $app_name
		if [ "$?" -ne 0 ]
		then
			fatty_log -l ERROR -m  "failed to install $local_app_file into $deploycenter"
			exit 1
		fi
	fi
done

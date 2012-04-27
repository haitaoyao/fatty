#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-06-29.13:54:19
#
# used to install the application packages into repository for deployment
#
##################################################################
current_dir=$(cd $(dirname $0);pwd)

#set the environment variables
. $current_dir/script_env.sh
. $current_dir/common.sh

#print the script help info
print_help()
{
	echo
	echo "This is used to install the application archive file into the fatty repository"
	echo "Usage: $0 -f app_file -n app_name -m message_for_install -v app_version "
	printf "\t-f\t the application archive file \n"
	printf "\t-n\t the application name used to identify\n"
	printf "\t-m\t the messge for this installation\n"
	printf "\t-v\t the version of the app package to install, default is 1.0\n"
#	printf "\t-d\t the deploy center to install into . ALL means all the deploy center should be installed. Use , to split multiple deploy centers"
	echo
}
if [ -z "$1" ]
then
	print_help
	exit 1
fi
while getopts ":f:n:m:v:" OPT
do
	case $OPT in
		f)
			app_file=$OPTARG
			;;
		n)
			app_name=$OPTARG
			;;
		#d)
			#deploy_centers="1"
			#;;
		m)
			install_message=$OPTARG
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

if [ -z "$app_file" -o ! -f $app_file -o -z "$app_name" ]
then
	print_help
	exit 1
fi 

if [ -z "$(file $app_file -b |grep gzip)" ]
then
	echo "$app_file is not a gzip file, can't accept other file type"
	exit 1
fi 

if [ -z "$app_version" ]
then
	app_version='1.0'
	fatty_log -l "WARN" -m "no version specified, use 1.0 as default"
fi
# get the local storge location for repository
get_local_storage_location()
{
	local_storage_location=$(read_fatty_config "storage_location")	
	if [ ! -d $local_storage_location ]
	then	
		mkdir -p $local_stoarge_location
		fatty_log -m  "local stoarge location: $local_stoarge_location created"
	fi
	app_storage_location=$local_storage_location/$app_name/$(date +%Y%m)
	if [ ! -d $app_storage_location ]
	then
		mkdir -p $app_storage_location
		fatty_log -m  "app location: $app_storage_location created"
	fi
	
}


check_and_log_md5()
{
	old_file_md5=$(md5sum $app_file|awk '{print $1}')	
	new_file_md5=$(md5sum $app_storage_location/$final_app_file_name|awk '{print $1}')
	if [ x"$old_file_md5" != x"$new_file_md5" ]
	then
		fatty_log -l ERROR -m'md5 not match , old: $old_file_md5, new: $new_file_md5'
		exit 1
	fi
	echo "$new_file_md5" > $app_storage_location/$final_app_file_name.md5
}

get_local_storage_location

# check the version violation
existing_files=$(find $local_storage_location/$app_name -type f -name "${app_name}___${app_version}___*.tar.gz")

if [ ! -z "$existing_files" ]
then
	fatty_log -l ERROR -m" existing vesion: $app_version, file: $existing_files\n"
	print_help
	exit 1
fi
final_app_file_name=${app_name}___${app_version}___$(get_timestamp).tar.gz
cp $app_file $app_storage_location/$final_app_file_name
check_and_log_md5
if [ "$?" -ne 0 ]
then
	exit 1
fi
fatty_log -m  "$app_file installed into : \n\t$app_storage_location/$final_app_file_name\n\tmd5sum: $(md5sum $app_storage_location/$final_app_file_name|awk '{print $1}')"
if [ ! -z "$install_message" ]
then
	echo $install_message > $app_storage_location/$final_app_file_name.info
fi
fatty_log -m  "\n\n\n\t$final_app_file_name installed\n\n\n"



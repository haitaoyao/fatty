#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-07-11.16:37:55
# 
# used to get the nginx upstream servers 
#
##################################################################

current_dir="$(cd $(dirname $0);pwd)"

#print help
print_help()
{
	echo
	echo "This is used to get the upstream servers of nginx"
	echo "Usage: $0 -d nginx_home -h nginx_address -u nginx_user"
	printf "\t-d\t the nginx home folder (optional, default: /opt/nginx)\n"
	printf "\t-h\t the nginx web server address\n"
	printf "\t-u\t the nginx user (optional, default: root)\n"
	echo
}

if [ -z "$1" ]
then
	print_help
	exit 1
fi

while getopts ":h:d:u:" OPT
do
	case $OPT in
		d)
			nginx_home=$OPTARG
			;;
		h)
			nginx_address=$OPTARG
			;;
		u)
			nginx_user=$OPTARG
			;;
		?)
			print_help
			;;
		:)
			print_help
			exit 1
			;;
	esac
done
if [ -z "$nginx_home" ]
then
	nginx_home='/opt/nginx'
fi
if [ -z "$nginx_address" ]
then
	print_help
	exit 1
fi

if [ -z "$nginx_user" ]
then
	nginx_user="root"
fi

ssh $nginx_user@$nginx_address "grep -Eo 'server [0-9].*{2,3}' $nginx_home/conf/nginx.conf"

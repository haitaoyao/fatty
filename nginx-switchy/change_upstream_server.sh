#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-07-11.16:57:37
# 
# used to change the nginx upstream server list
# 
##################################################################
current_dir="$(cd $(dirname $0);pwd)"

#print help
print_help()
{
	echo
	echo "This is used to change the nginx upstream server list"
	echo "Usage: $0 -d nginx_home -u nginx_user -h nginx_address -s server_list -r"
	printf "\t-d\t the nginx home folder\n"
	printf "\t-h\t the nginx web server address\n"
	printf "\t-u\t the nginx user (optional, default: root)\n"
	printf "\t-s\t the nginx upstream server list, format: ip:port#weight,ip:port#weight....\n"
	printf "\t-r\t (optional) reload the nginx after the configuration is changed \n"
	echo
}


if [ -z "$1" ]
then
	print_help
	exit 1
fi
while getopts ":h:d:u:s:r" OPT
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
		s)
			nginx_server_list=$OPTARG
			;;
		r)
			reload_nginx='1'
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

if [ -z "$nginx_home" -o -z "$nginx_address" -o -z "$nginx_server_list" ]
then
	print_help
	exit 1
fi

if [ -z "$nginx_user" ]
then
	nginx_user="root"
fi

scp $current_dir/do_change_nginx_config.sh $nginx_user@$nginx_address:/tmp
ssh $nginx_user@$nginx_address "bash /tmp/do_change_nginx_config.sh $nginx_home $nginx_server_list"
exit_code=$?
if [ "$exit_code" -ne 0 ]
then
	echo "change config error"
	exit $exit_code
fi
if [ ! -z "$reload_nginx" ]
then
	ssh  $nginx_user@$nginx_address 'killall -HUP nginx'
	echo "nginx reloaded"
fi

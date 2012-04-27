#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-07-11.17:33:29
# 
# 
# 
##################################################################
current_dir="$(cd $(dirname $0);pwd)"

nginx_home=$1
server_list=$2

if [ -z "$1" -o -z "$2" ]
then
	echo "Usage: $0 nginx_home server_list"
	exit 1
fi
nginx_config_file=$nginx_home/conf/nginx.conf
if [ ! -f "$nginx_config_file" ]
then
	echo "No config file @ $nginx_config_file"
	exit 1
fi

sed  '/server [0-9]\{2,\}.*/d' $nginx_config_file > ${nginx_config_file}.tmp
get_server_address()                                                       
{       
        echo $1 | awk -F '#' '{print $1}' 
}
get_server_weight()                                                        
{       
        echo $1 | awk -F '#' '{print $2}'
} 
for server_arg in $(echo $server_list |awk -F , '{for(i=1;i<=NF;i++){print $i}}' )
do
	IP=$(get_server_address $server_arg)
	WEIGHT=$(get_server_weight $server_arg)
	if [ -z "$IP" -o -z "$WEIGHT" ]
	then
		echo "error to parse the server list: $server_list"
		exit 1
	fi
	sed -i "/#HE_NGINX_SERVER/a\\ \tserver $IP  weight=$WEIGHT;" ${nginx_config_file}.tmp
done

cp $nginx_config_file ${nginx_config_file}.last
mv ${nginx_config_file}.tmp $nginx_config_file


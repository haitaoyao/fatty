#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-06-30.15:52:38
# 
# used to install the application archiver to deploy center
#
##################################################################
current_dir=$(cd $(dirname $0);pwd)
. $current_dir/script_env.sh
. $current_dir/common.sh
app_file_name=$1
app_file=$2
deploycenter=$3
app_name=$4

get_deploycenter_address()
{
	cat $FATTY_CONFIG_HOME/$deploycenter.deploy.conf|grep address|awk -F "address=" '{print $2}'
}
get_deploycenter_user()
{
	cat $FATTY_CONFIG_HOME/$deploycenter.deploy.conf|grep address|awk -F "user=" '{print $2}'
}
if [ -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]
then
	echo "Usage: $0 app_file_name app_file deploycenter app_name"
	exit 1
fi

deploycenter_location=/data/fatty/$app_name
deploycenter_user=$(get_deploycenter_user)
if [ -z "$deploycenter_user" ]
then
	deploycenter_user=$FATTY_USER
fi
deploycenter_address=$(get_deploycenter_address)
if [ -z "$deploycenter_address" ]
then
	fatty_log -m "no address configured for $deploycenter"
	exit 1
fi
tmp_dir=$FATTY_TMP_DIR/$app_name/$(date +%Y%m%d%H%M%S.%N)


# ugly script below!
# I really have no idea how to make it better, maybe this is what "boring job" means.
mkdir -p $tmp_dir
cp $app_file $tmp_dir
cd $tmp_dir/
tar zxvf $app_file -C $tmp_dir
rm $tmp_dir/$app_file_name
rsync -av --delete $tmp_dir/ $deploycenter_user@$deploycenter_address:$deploycenter_location/current/

ssh $deploycenter_user@$deploycenter_address "if [ ! -d $deploycenter_location/history ];then mkdir -p $deploycenter_location/history; fi; cd $deploycenter_location/current/; tar zcvf $deploycenter_location/history/$app_file_name *"

cd /tmp
rm -rf $tmp_dir


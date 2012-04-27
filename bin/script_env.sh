#!/bin/bash
##################################################################
# 
# written by haitao.yao @ 2011-06-29.14:24:50
# 
# used to set the environment variables.
#
##################################################################

FATTY_SCRIPT_HOME=$(cd $(dirname $0)/../;pwd)
FATTY_CONFIG_HOME=$FATTY_SCRIPT_HOME/config

#temp dir for fatty execution
FATTY_TMP_DIR=/tmp/fatty
if [ ! -d "$FATTY_TMP_DIR" ] 
then
	mkdir -p $FATTY_TMP_DIR
fi
# log dir for fatty
FATTY_LOG_DIR=/tmp/fatty/logs
if [ ! -d $FATTY_LOG_DIR ]
then
	mkdir -p $FATTY_LOG_DIR
fi

# user name used for fatty
FATTY_USER=arch

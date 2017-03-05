#!/bin/sh

current_dir=$(pwd)

current_hour=$(date +%H)

if [ ${current_hour} -eq 1 ] ; then
	if [ -f ${current_dir}/sync_ready ] ; then
		'rm' -f ${current_dir}/sync_ready
	fi

	sh ${current_dir}/createreposyc.sh
else
	if [ -f ${current_dir}/sync_ready ] ; then
		sh ${current_dir}/createreposyc.sh
		'rm' -f ${current_dir}/sync_ready
	fi
fi
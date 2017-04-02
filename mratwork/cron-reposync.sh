#!/bin/sh

current_dir=${PWD}

current_hour=$(date +%H)

cd ${current_dir}

if [ ${current_hour} -eq 1 ] ; then
	if [ -f ${current_dir}/ready_sync ] ; then
		'rm' -f ${current_dir}/ready_sync
	fi

	sh ${current_dir}/createreposync.sh > ${current_dir}/reposync.log
else
	if [ -f ${current_dir}/ready_sync ] ; then
		'rm' -f ${current_dir}/ready_sync
		sh ${current_dir}/createreposync.sh > ${current_dir}/reposync.log
	fi
fi

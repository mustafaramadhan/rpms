#!/bin/sh

T="$(date +%s%N)"

yum clean all

if [ "$(rpm -qa createrepo)" == "" ] ; then
	yum install createrepo -q -y
fi

CURRPATH=${PWD}
cd ${CURRPATH}

CURRBASENAME=${CURRPATH##*/}

if [ "${CURRBASENAME}" != "mratwork" ] ; then
	echo
	echo "* Your current path is '${CURRPATH}'"
	echo "  - Need path as '/home/rpms/<domain>/repo/mratwork'"
	echo "    where 'rpms' as client in Kloxo-MR 7.0"
	echo
	exit
fi

if [ "$(yum list *yum*|grep '@')" == "" ] ; then
	OPTIONS=""
else
	OPTIONS="--no-database --checksum=sha"
fi

wget -r -l 1 -N -nd -R "index.html" http://rpms.mratwork.com/repo/mratwork/
'cp' reposync.phpfile reposync.php

if [ ! -d ${CURRPATH}/mirror ] ; then
	mkdir -p ${CURRPATH}/mirror
fi

cd ${CURRPATH}/mirror
wget -r -l 1 -N -nd -R "index.html" http://rpms.mratwork.com/repo/mratwork/mirror

cd ${CURRPATH}
wget -r -l 1 -N -nd -R "index.html" http://rpms.mratwork.com/repo/mratwork

if [ ! -d ${CURRPATH}/SRPMS ] ; then
	mkdir -p ${CURRPATH}/SRPMS
fi

chmod -R o-w+r ${CURRPATH}

cd ${CURRPATH}

echo "*** Process for SRPMS..."

reposync --norepopath --source --config=mratwork-reposync.repo \
	--delete \
	--repoid=mratwork-srpms \
	--download_path=${CURRPATH}/SRPMS

createrepo ${OPTIONS} ${CURRPATH}/SRPMS

for type in release testing ; do
	for ver in centos5 centos6 centos7 neutral ; do
		for item in i386 x86_64 noarch ; do
			if [ ! -d ${CURRPATH}/${type}/${ver}/${item} ] ; then
				mkdir -p ${CURRPATH}/${type}/${ver}/${item}
			fi
			echo "*** Process for '${type}-${ver}-${item}'..."
			reposync --norepopath --config=mratwork-reposync.repo \
				--delete \
				--repoid=mratwork-${type}-${ver}-${item} \
				--download_path=${CURRPATH}/${type}/${ver}/${item}
			createrepo ${OPTIONS} ${CURRPATH}/${type}/${ver}/${item}
		done
	done
done

cd ${CURRPATH}

sh /script/fix-chownchmod --client=rpms

# Time interval in nanoseconds
T="$(($(date +%s%N)-T))"
# Seconds
S="$((T/1000000000))"
# Milliseconds
M="$((T/1000000))"

echo ""
printf "*** Process Time: %02d:%02d:%02d:%02d.%03d (dd:hh:mm:ss:xxxxxx) ***\n" \
	"$((S/86400))" "$((S/3600%24))" "$((S/60%60))" "$((S%60))" "${M}"
echo ""


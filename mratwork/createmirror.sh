#!/bin/bash

T="$(date +%s%N)"

if [ "$(rpm -qa createrepo)" == "" ] ; then
	yum install createrepo -q -y
fi

CURRPATH=${PWD}
CURRBASENAME=${PWD##*/}

echo "* Start for mratwork.repo mirror"

if [ -d /var/cache/yum ] ; then
	'rm' -rf /var/cache/yum/*
fi

if [ ! -f $CURRPATH/mratwork-mirror.repo ] ; then
	echo
	echo "  - Need '$CURRPATH/mratwork-mirror.repo' file"
	echo
	exit
fi

if [ "$(yum list *yum*|grep '@')" == "" ] ; then
	crOPTIONS=""
	csOPTIONS=""
else
	crOPTIONS="--no-database --checksum=sha"
	csOPTIONS="--norepopath"
fi

cd $CURRPATH

if [ ! -d $CURRPATH/mirror ] ; then
	mkdir -p $CURRPATH/mirror
fi

### MR -- release/testing portion ###
for a in release testing ; do
	for b in neutral centos5 centos6 centos7 ; do
		for c in noarch i386 x86_64 ; do
			if [ ! -d $CURRPATH/$a/$b/$c ] ; then
				mkdir -p $CURRPATH/$a/$b/$c
			fi

			echo "  - Processing for './$a/$b/$c'"
			mv -f $CURRPATH/$a/$b/$c $CURRPATH/$a/$b/$a-$b-$c
			echo "    - Getting rpm files"
			reposync $csOPTIONS \
				--quiet --delete --arch=$c --config=$CURRPATH/mratwork-mirror.repo \
				--repoid=$a-$b-$c --download_path=$CURRPATH/$a/$b/$a-$b-$c

			if [ -d $CURRPATH/$a/$b/$a-$b-$c ] ; then
				mv -f $CURRPATH/$a/$b/$a-$b-$c $CURRPATH/$a/$b/$c
			fi

			createrepo $crOPTIONS --quiet --checkts --update $CURRPATH/$a/$b/$c

			echo "    - Getting mirror list"
			wget https://github.com/mustafaramadhan/kloxo/raw/rpms/mirror/mratwork-$a-$b-$c-mirrors.txt \
				--output-document=$CURRPATH/mirror/mratwork-$a-$b-$c-mirrors.txt --no-check-certificate \
				 >/dev/null 2>&1

		done
	done
done

if [ ! -d $CURRPATH/SRPMS ] ; then
	mkdir -p $CURRPATH/SRPMS
fi

echo "  - Processing for './SRPMS'"

echo "    - Getting rpm files"

### MR -- SRPMS portion ###
reposync $csOPTIONS --source \
	--quiet --delete --arch=SRPMS --config=$CURRPATH/mratwork-mirror.repo \
	--repoid=srpms --download_path=$CURRPATH/SRPMS

createrepo $crOPTIONS --quiet --checkts --update $CURRPATH/SRPMS

echo "    - Getting mirror list"
wget https://github.com/mustafaramadhan/kloxo/raw/rpms/mirror/mratwork-SRPMS-mirrors.txt \
	--output-document=$CURRPATH/mirror/mratwork-SRPMS-mirrors.txt --no-check-certificate \
	 >/dev/null 2>&1

echo "* End for mratwork.repo mirror"

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


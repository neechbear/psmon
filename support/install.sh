#!/bin/sh
############################################################
#
#   $Id: install.sh,v 1.11 2005/12/30 02:06:27 nicolaw Exp $
#
#   Copyright 2002,2003,2004,2005 Nicola Worthington
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
############################################################

Target="/usr/bin"

if ! [ -f support/psmon.html ] && [ -f psmon.html ] && [ -f ../Makefile.PL ]
then
	cd ..
fi

for dm in wget lwp-download ncftpget
do
	if which $dm > /dev/null 2>&1
	then
		Download=$dm
	fi
done

# Check we have all the right perl modules installed. Try and
# install them from the tarballs provided if necessary.
echo "Config General 2.27,Proc ProcessTable 0.39,Unix Syslog 0.99,Getopt Long 2.34," | \
	while read -d',' Group Name Version
do
	m="$Group::$Name"
	mf="$Group-$Name-$Version.tar.gz"
	md="$Group-$Name"
	echo -n "Checking for $m ... "
	if perl -e '$m = shift; eval("use $m;"); exit 1 if $@;' $m
	then
		echo "found"
	else
		echo "missing"
		if [ "X$Download" != "X" ]
		then
			echo "Attempting to download $mf using $Download ..."
			$Download ftp://ftp.funet.fi/pub/languages/perl/CPAN/modules/by-module/$Group/$mf
			if [ -f $mf ]
			then
				echo "Attempting to install $m from $mf ..."
				tar -zxf $mf
				if cd $md-* > /dev/null 2>&1
				then
					perl Makefile.PL && make && make test && make install
					cd ..
				else
					echo "Failed to install $m from $mf; could not file extraction directory"
				fi
			else
				echo "Failed to download $mf"
			fi
		fi
	fi
done

# Install psmon
if [ -e bin/psmon ]
then
	# Remove any old version of psmon
	for file in psmon psmon-config
	do
		if which $file > /dev/null 2>&1
		then
			oldfile=`which $file`
			bakfile=`date +"$oldfile-%Y%m%d%H%M%S"`
			echo -n "Moving old $file $oldfile to $bakfile ... "
			mv $oldfile $bakfile
			if [ -e $bakfile ]; then echo "done"; else echo "failed"; fi
		fi

		# Install the new psmon script
		echo -n "Installing $file ... "
		cp bin/$file $Target/
		if [ -e $Target/$file ]; then
			echo "done"
			chmod 755 $Target/$file
		else
			echo "failed"
		fi

		# If we removed an old version, symlink it to the new version
		if [ "X$oldfile" != "X" ] && [ "$oldfile" != "$Target/$file" ]
		then
			echo -n "Symlinking old $file $oldfile to $Target/$file ... "
			ln -s $Target/$file $oldfile
			if [ -e $oldfile ]; then echo "done"; else echo "failed"; fi
		fi
	done

	# Install psmon.conf
	if ! [ -e /etc/psmon.conf ]
	then
		if [ -e etc/psmon.conf ]
		then
			echo -n "Installing etc/psmon.conf ... "
			cp etc/psmon.conf /etc
			if [ -e /etc/psmon.conf ]; then echo "done"; else echo "failed"; fi
		else
			echo -n "Could not find etc/psmon.conf; skipped etc/psmon.conf installation"
		fi
	else
		echo "/etc/psmon.conf already exists; skipped etc/psmon.conf installation"
	fi

	# Generate HTML documentation
	if which pod2html > /dev/null 2>&1
	then
		echo -n "Generating HTML documentation support/psmon.html ... "
		pod2html --css=support/perldoc.css bin/psmon > support/psmon.html
		if [ -e support/psmon.html ]; then echo "done"; else echo "failed"; fi
	fi

	# Generate and install man pages
	if which pod2man > /dev/null 2>&1
	then
		mandir=/usr/man/man1
		if ! [ -d $mandir ] && [ -d /usr/share/man/man1 ];then
			mandir=/usr/share/man/man1
		fi
		echo -n "Installing manual psmon.1 ... "
		pod2man bin/psmon > $mandir/psmon.1
		if [ -e $mandir/psmon.1 ]; then echo "done"; else echo "failed"; fi
	else
		echo "Could not find pod2man; skipped manual installation"
	fi
else
	echo "Could not find psmon; skipped psmon installation"
fi




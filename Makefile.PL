require 5.005;
use strict;
use ExtUtils::MakeMaker qw(WriteMakefile);

WriteMakefile(
	NAME			=> 'psmon',
	VERSION_FROM	=> 'bin/psmon',
	AUTHOR			=> 'Nicola Worthington <nicolaw@cpan.org>',
	ABSTRACT_FROM	=> 'bin/psmon',
	EXE_FILES		=> [ ('bin/psmon','bin/psmon-config') ],

	dist			=> {
				'COMPRESS'	=> 'gzip -9f',
				'SUFFIX'	=> 'gz',
				'ZIP'		=> '/usr/bin/zip',
				'ZIPFLAGS'	=> '-rl',
			},

	PREREQ_PM		=> {
				'Getopt::Long'			=> 0,
				'Config::General'		=> 0,
				'POSIX'					=> 0,
				'Proc::ProcessTable'	=> 0,
				'Net::SMTP'				=> 0,
				'Unix::Syslog'			=> 0,
			},
);



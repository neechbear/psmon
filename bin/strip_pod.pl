#!/usr/bin/perl -w

# $Id: strip_pod.pl,v 1.3 2005/03/02 11:32:46 nicolaw Exp $
# For internal development refactoring use only

use strict;
use warnings;

my ($code,$pod) = ('','');

{
	open(FH,'<psmon') || die "Unable to open file handle FH for file 'psmon': $!";
	local $/ = undef;
	while (<FH>) { $code .= $_; }
	close(FH) || warn "Unable to close file handle FH for file 'psmon': $!";
}

while ($code =~ s/=pod(\n.+?\n)=cut\n//s) {
	$pod .= $1;
}

print STDOUT $code;
print STDERR $pod;


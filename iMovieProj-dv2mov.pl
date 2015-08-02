#!/usr/bin/perl -w

use strict;

use File::Find;
use File::Slurp;
use File::Copy;

find(\&wanted, shift);

sub wanted {
	next unless /[^\~]\.iMovieProj$/;
	
	my $str = read_file($_);
	
	my $new = $str;
	$new =~ s/\.dv<\/string>/\.mov<\/string>/gism;
	
	print "$_\n";
	if (length($new) != length($str)) {
		print "   success. subbed .dv for .mov\n";
		print "   copy \"$_\" ---> \"$_\.bak\"\n";
		copy($File::Find::name, "$File::Find::name\.bak") || die;
		#move($File::Find::dir/Media \(mov\))
		#print "$new";
		write_file($File::Find::name,$new);
	} else {
		print "   same file. no change"
	}
	

}

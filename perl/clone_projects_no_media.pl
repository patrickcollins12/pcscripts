#!/usr/bin/perl -w
use strict;

use File::Find;
use File::Path qw(make_path);
use File::Copy qw(copy);
use File::Slurp qw(read_file write_file);
my $dest = "/tmp/MovieProjects";
find(\&wanted, shift);

sub wanted {
	return unless /\.iMovieProj$/;
	return if /\~\.iMovieProj$/;
	print "\n# $File::Find::name\n";
	
	my $newdir = $File::Find::dir;
	$newdir =~ s/^[\.\/](.*?)\/?/$1/g;
	my $newpath = "$dest/$newdir/";

	make_path($newpath) || die ("Couldn't make_path $newpath: $!");

	# Read the file. Sub dv for mov, write it to the new location.
	my $text = read_file($_);
	$text =~ s/\.dv\</.mov</gi;
	my $newfile = "$newpath$_";
	print length($text) . " $newfile\n";
	write_file($newfile,$text);
}
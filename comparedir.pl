#!/usr/bin/perl -w

# Simple diff -r --brief replacement
use File::Basename;
use List::Compare;
use strict;

my $dir1 = shift;
my $dir2 = shift;
my $col = 40;

compare($dir1,$dir2);
#multiple_dirs($dir1,$dir2);

sub multiple_dirs {
	my ($dir1,$dir2) = @_;
	my @dir1 = getdir($dir1);
	my @dir2 = getdir($dir2);
	my (%dirs1,%dirs2);
	my @dir1 = map { my $s = @_; s/(.*)\.iMovieProject/$1/;$dirs1{$_}=$s; $_;} @dir1;
	my @dir2 = map { my $s = @_; s/(.*)\.iMovieProject/$1/;$dirs2{$_}=$s; $_;} @dir2;
	print "DIR1 --- " . join("   ",@dir1) . "\n";
	print "DIR2 --- " . join("   ",@dir2) . "\n";

	my @uniq = uniq((keys %dirs1,keys %dirs2));
	print "UNIQ --- " . join("   ",@uniq) . "\n";
	# print "@uniq\n";

	foreach my $i (sort @uniq) {
		print "\n--- $i\n";
		my $i1 = $i;
		#$i1 =~ s/\/$/\.iMovieProject/g;
		compare("$dir1/$i1/Original Media","$dir2$i/");
	}	
}


sub uniq {local %_; grep {!$_{$_}++} @_} 


sub compare {
	my ($dir1, $dir2) = @_;
	
	my @files1 =  getdir("$dir1");
	my @files2 =  getdir("$dir2");

	my (%l,%r,%b);
	foreach my $i (@files1) {
		$b{lc($i)}++;
		$l{lc($i)}++;
	}
	foreach my $i (@files2) {
		$b{lc($i)}++;
		$r{lc($i)}++;
	}
	
	# PRINT HEADERS
	my $d1 = (-d "$dir1") ? "ok":"no dir";
	my $d2 = (-d "$dir2") ? "ok":"no dir";
	print "<<< $dir1 (d1 $d1)\n";
	print ">>> $dir2 (d2 $d2)\n";
	# my @la = unpack "(a$col)*", $dir1;
	# my @ra = unpack "(a$col)*", $dir2;
	# my $max = ($#la>$#ra) ? $#la:$#ra;
	# for (my $i=0; $i<=$max; $i++) {
	# 	if ($i <= $#la) {
	# 		printf("%${col}s",$la[$i]);
	# 	} else {
	# 		printf("%${col}s"," ");
	# 	}
	# 	print " "x6;
	# 	if ($i <= $#ra) {
	# 		printf("%${col}s",$ra[$i]);
	# 	}
	# 	print "\n";
	# }
	# print "-"x$col, " "x6, "-"x$col, "\n";
	

	# PIRNT DIRECTORY
	foreach my $i ( sort keys %b) {
		if ( defined $l{$i} ){
			printf("%${col}s      ", $i);
		} else {
			printf("%${col}s      ", " " );
		}
		
		if ( defined $r{$i} ){
			printf("%${col}s\n", $i);
		} else {
			print "\n";
		}
	}	
}

sub getdir {
	my($dir) = @_;
	if (! opendir(D, $dir) ) {
		#print "Can't open directory: $dir: $!\n";	
		return;
	} 
	
	my @dir;
	while (my $f = readdir(D)) {
		next if $f =~ /^\.\.?$/;
		if (-d "$dir/$f") {
			$f.="/";
		}
	    push(@dir,$f);
	}
	closedir(D);

	return @dir;
}
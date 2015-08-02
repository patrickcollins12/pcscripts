#!/usr/bin/perl -w
use strict;
use File::Find;
use File::stat;
	
my @skip_dirs = (
	"QuickLook",
	"Thumbnails",
	"Proxies",
	"GarageBand",
	"Thumbnails",
	"Shared Movies",
	"Cache",
	"iDVD",
	);

my @skip_files = (
	qr"\~\.iMovieProj$",
	qr"\.bak$",
	qr"\.DS_Store",
	qr"^Icon",
	qr"^Still",
	qr"Fade In",
	qr"Fade Out",
	qr"Subtitle",
	qr"Centered Title",	
	qr"^Ripple",	
	qr"^Reflection",	
	);

my %files;
find(\&wanted,@ARGV);

sub wanted{
	return if -d;
	
	my $d = $File::Find::name;
	#print ">>>> $d\n";
	foreach my $i ( @skip_dirs) {
		if ( $d=~ /$i/ ) {
			#print "   Testing $i match for $d. Skipping\n";
			return;
		}
	}

	foreach my $i (@skip_files) {
		if (  $_ =~ /$i/ ) {
			#print "   Testing $i match for $_. Skipping\n";
			return;
		}
	}
	

 	my $st = stat($_) or die "No $_: $!";
 
	my %entry;
	$entry { 'full' } = $d;
	$entry { 'size' } = $st->size;
	$entry { 'mtime' } = $st->mtime;
	$entry { 'inode' } = $st->ino;
	push(@{$files{$_}}, \%entry);
	
	#print "$File::Find::name\n";
}

use Data::Dumper;
#print Dumper \%files;

foreach my $f (keys %files ) {
	my @entries = @{$files{$f}};
	my $count_entries = $#entries+1;
	if ($count_entries > 1 ) {
	} else {
		next;
	}
	
	
	for (my $i=0; $i<$count_entries; $i++) {
		#print "$f\n";
		#print "---" . Dumper($entries[$i]{'size'});
		
		my $isize = $entries[$i]{'size'};
		my $iinode= $entries[$i]{'inode'};
		my $ifull = $entries[$i]{'full'};
		my $iter=0;
		

		for (my $j=$i+1; $j<$count_entries; $j++) {
			my $jsize = $entries[$j]{'size'};
			my $jinode= $entries[$j]{'inode'};
			my $jfull= $entries[$j]{'full'};
			
			if ($isize == $jsize) {
				if ($iinode == $jinode) {
					print "same inode $jfull ($jinode) $ifull ($iinode)\n";
				} else {
					# print "$f clash\n" unless $iter;
					# print "   size=$isize inode=$iinode $ifull\n" unless $iter;
					# print "   size=$jsize inode=$jinode $jfull\n";
					#print "$ifull size=$isize inode=$iinode\n" unless $iter;
					print "$jfull size=$jsize ($jinode) $ifull ($iinode)\n";					
				}

				$iter++
			}
		}
	}
	
}

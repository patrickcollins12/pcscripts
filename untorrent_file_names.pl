use strict;

use File::Find;
use File::Copy;

my $dir = shift;

find(\&wanted,$dir);


#$File::Find::dir  = /some/path/
#$_                = foo.ext
#$File::Find::name = /some/path/foo.ext
sub wanted {
	my $orig = $_;
	my $d = $File::Find::dir;
	
	if ( -d ) {
		print " - $orig\/\n";
	}
	
	if ( -f && /(.*)(\....\'?)$/ ) {
		print " -- $orig\n";
		my $base = $1;
		my $ext = $2;
		$base =~ s/\./ /g;


		# delete images and nfo
		if ( $orig =~ /\.(nfo|jpg|png|gif)$/ ) {
			print "$orig\n";
			if (ask("Delete img?")) {
				unlink($orig);	
				return;			
			}
		}

		# delete subtitle files?
		if ( $orig =~ /\.(srt)$/ ) {
			print "$orig\n";
			if (ask("Delete srt?")) {
				unlink($orig);	
				return;			
			}
		}

		# delete txt files?
		if ( $orig =~ /\.(txt)$/i ) {
			print "$orig\n";
			if (ask("Delete?")) {
				unlink($orig);	
				return;			
			}
		}
			
		# Case insensitive
		$base =~ s/[\s-]*\b(YIFY|WEBDL|bajskorv|w4f|400P|MP4|Secludedly|2HD|x264|R5|PublicHD|anoXmous_eng|SDH|SAMPLE|anoXmous_|Rifftrax|ETRG|2ch|AAC|KILLERS|EVO|BOKUTOX|RARBG|FXM|WBZ|DD5|H264|FLAWL3SS|NYDIC|ACAB|MAXSPEED|6CH|ShAaNiG\scom|www.torentz.3xforum.ro|DVD-Rip|WEB-DL|KLAXXON|READNFO|AC3|HELLRAZ0R|MP3|DTS|WIKI|nogrp|axxo|hdrip|AC3-JYK|FXG|DTS-JYK|hc|xvid|brrip|webrip|DIMENSION|LOL|DVDRip|HDTV|Sir.Paul|EbiXVid|FUM|Bluray)\b//gi;

		# Case sensitive (don't want to catch common words)
		$base =~ s/[\s-]*\b(Eng|VectoR|FoV|FuckGov|mSD|IMMERSE|RM-ASAP|ASAP|MIKY|RiVER|EVOLVE|fqm|ViSiON|PROPER|LiNE|WS|IMAGiNE|sm|DEViSE|LiMiTED|DiVERSE|PrisM)\b//g;

		$base =~ s/HDTV/1080p/g;
		$base =~ s/[-\s\(\[]*(1080p|720p|480p)[\]\)]*/ [$1]/g;

		
		$base =~ s/[\s\(\[]*(19|20)(\d\d)[\]\)]*/ \($1$2\)/g;

		
		$base =~ s/\(\)//g;
		$base =~ s/\[\]//g;
		$base =~ s/\s+/ /g;
		$base =~ s/\s+$//g;
		
		my $new = $base . $ext;
		
		$new =~ s/^\'(.*?)\'$/$1/g;
		
		if ($new eq $orig) {
	    	print "Skipping $orig\n";
		} 
		
		
		# Ask and then rename it
		else {
			if ($d eq "." ) { 
			} else {
				print "\$ $d\n";
			}
			
			print "mv $orig\n   $new\n";
			if ( ask("Rename?") ) {
				#rename($orig,$new);
				move($orig,$new) || die "Move failed: $!";
				print " ... renamed\n";
			} else {
				print " ... skipped\n";
			}

			# Ask to move the file up a level?
			print "mv $new ..?\n";			
			if ( ask("Move up ..?") ) {
				move($new, "..") || die "Move failed: $!";
				
				print "Delete ../$d?\n";
				if ( ask("Delete containing directory if empty?") ) {
					rmdir "../$d" || print "Directory removal failed: $!";
				}
			}
		}

    } else {
    	print "Skipping $_\n";
    }
	print "\n";
}

# prompt should contain a question like rename? delete?
sub ask {
	my($prompt)  = @_;
	print "$prompt (y|n) > ";
	my $answer = <STDIN>;
	chomp $answer;
	if ($answer eq "" || $answer =~ /^[y\']$/i ) {
		return 1;
	} else {
		return 0;
	}
}


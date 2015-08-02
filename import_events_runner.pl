#!/usr/bin/perl -w

use strict;

my @events = <"/Volumes/PatrickWD/iMovie\ Library\ 18.imovielibrary/[0-9]*/Original\ Media">;
my $library = "/Volumes/PatrickWD/iMovie\ Library\ 18.fcpbundle";

my $i;
my $trigger=0;
foreach my $event_dir (@events) {

	print $event_dir . "\n";
	if ($event_dir =~ /jelly belly/) {
		print ">>>>";
		$trigger=1;
	}
	next unless $trigger;
	
	# Grab the last part of the directory and use that as the event name
	my $event_name = $event_dir;
	$event_name =~ s/Original Media//g;
	$event_name =~ s/\/*$//g;
	$event_name =~ s/.*\/(.*?)$/$1/g;
		
	my $cmd = <<TOHERE;

perl ~/Documents/workspace/scripts/import_events_fcpxml.pl \\
 --output_xml=/tmp/output.fcpxml \\
 --event "$event_name RAW" \\
 --library "$library"\\
 --media_dir "$event_dir" && \\
 open /tmp/output.fcpxml

TOHERE

print $cmd;
print `$cmd`;

sleep (10);
#print "Press ENTER to exit:";
#<STDIN>;


}

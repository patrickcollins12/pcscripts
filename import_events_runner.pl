use strict;

my @events = <"/Volumes/PatrickWD\ 1/iMovie\ 10\ Library\ External.imovielibrary/[0-9]*/Original\ Media">;
my $library = "/Volumes/PatrickWD\ 1/iMovie\ 10\ Library\ External.fcpbundle";

my $i;
foreach my $event_dir (@events) {

	# Grab the last part of the directory and use that as the event name
	my $event_name = $event_dir;
	$event_name =~ s/Original Media//g;
	$event_name =~ s/\/*$//g;
	$event_name =~ s/.*\/(.*?)$/$1/g;
		
	my $cmd = <<TOHERE;

perl ~/Documents/workspace/scripts/import_events_fcpxml.pl \\
 --output_xml=/tmp/output.fcpxml \\
 --event "$event_name" \\
 --library "$library"\\
 --media_dir "$event_dir" && \\
 open /tmp/output.fcpxml

TOHERE

print $cmd;
#print `$cmd`;

#sleep (4);

}

# sudo cpan
# password:
# cpan> install Mac::PropertyList::SAX

use strict;
use Mac::PropertyList::SAX qw(:all);
use File::Path qw(make_path);
use File::Copy;
use FileHandle;
use Time::Local;

# Expect 1 or 2 arguments
my $file = shift;
my $dir  = shift // "iPhotoMovies";

usage() unless ($file =~ /AlbumData.xml/);

# slurp in the whole xml file
print "Loading $file\n";
my $fh = FileHandle->new;
$fh->open($file) || die ("Couldn't open the XML file $file");
my $text;
while(<$fh>) {
	$text.=$_;
}
close $fh;	

# Parse the file
print "Parsing $file\n";
my $perl = parse_plist($text)->as_perl;

# Create an events hash
my %event_photo;
my %event;
foreach my $event ( @{ $perl->{'List of Albums'} } ) {
	my $t = $event->{'Album Type'};
    
	if ( $t eq "Event" ) {
		my $n = $event->{'AlbumName'};
		my $d = $event->{'ProjectEarliestDateAsTimerInterval'};
		my @p = @{ $event->{'KeyList'}};
	
		$event{ $n }{'date'} = $d;

        foreach my $pid ( @p ) {
            push( @{ $event_photo{ $n } }, $pid );
        }
    }
}

# Capture the path of all of the photos
my %images;
my $images = $perl->{'Master Image List'};
foreach my $pkey ( keys %$images ) {
    if ( $$images{$pkey}{'MediaType'} eq "Movie" ) {
        $images{$pkey}{'path'} = $$images{$pkey}{'ImagePath'};
    }
}

# Do the copy
foreach my $event ( keys \%event_photo ) {
    my $found = 0;
	my $date = yyyymmdd($event{$event}{'date'});
	
    foreach my $event_photo ( @{ $event_photo{$event} } ) {
        my $path = $images{$event_photo}{'path'};

		# Comment this line if you don't want the date on the event name
		$event = "$date $event";
		
        if ( defined $path ) {

            print "cp \"$path\" \"$dir/$event\"\n";
            make_path("$dir/$event");
            copy($path,"$dir/$event");
            $found++;
        }
    }
    print "\n" if $found;
}


# convert a plist date format to yyyy-mm-dd
sub yyyymmdd {
	my ($e) = @_;

	# Plist date format is from 2001-01-01. Let's add that to the date to get Unix epoch
	my $epoch2001 = timelocal( 0, 0, 0, 1, 0, 2001);
	my @time =localtime($e+$epoch2001);
	my $y = $time[5]+1900;
	my $m = $time[4]+1;
	my $d = $time[3];
	return sprintf("%d-%0.2d-%0.2d", $y,$m,$d);
}


sub usage {
	print "Usage: $0 <path_to>/AlbumData.xml [DestinationDirectory]\n";
	exit 1;
}

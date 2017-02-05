#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use FileHandle;
use URI::Encode qw(uri_encode uri_decode);



# Get the arguments
my $event;
my $library;
my $media_dir;
my $output_xml;

check_all_inputs();

# OPEN THE OUTPUT XML FILE
my $fh = FileHandle->new;
$fh->open(">$output_xml") or usage("Couldn't open $output_xml to write to");

# Get all of the files in the media_dir
my @files;
opendir(DIR,"$media_dir") || usage("Couldn't open media_dir $media_dir");
while (my $file = readdir(DIR)) {
	next if $file =~ /^\.\.?$/;
	push(@files,$file);
}
close DIR;

my $iter  = 1;
my $assets_xml;
if ( ! @files ) {
    print "No files in $media_dir\n";
    exit 1;
}

foreach my $file (@files) {
	my $full_file = "$media_dir/$file";
    print "   $full_file";
    if ( -f $full_file ) {
        print " .. inserting\n";
    }
    else {
        print " ... skipping\n";
 		next;
    }

	$full_file = uri_encode($full_file);
	$full_file =~ s/\&/%26/g;
	$full_file =~ s/\(/%28/g;
	$full_file =~ s/\)/%29/g;
	$full_file =~ s/\;/%3B/g;

    $assets_xml .= " " x 12
      . "<asset id=\"r$iter\" projectRef=\"e1\" src=\"file:$full_file\"/>\n";
    $iter++;
}


$event =~ s/\&/\&amp\;/g;
$event =~ s/\"/\&quot\;/g;
$event =~ s/\</\&lt\;/g;
$event =~ s/\>/\&gt\;/g;
$event =~ s/\'/\&apos\;/g;	
#$library = uri_encode($library);

my $file = <<TOHERE;
<fcpxml version="1.3">
   <import-options>
      <option key="library location" value="file:$library"/>
      <option key="copy assets" value="0"/>
   </import-options>

   <project name="$event">
      <resources>
         <projectRef id="e1" name="test event 3"/>
$assets_xml
      </resources>
    </project>
</fcpxml>
TOHERE

#print "$file\n";
# Savet the xml to the output file
print $fh $file;

###################################
sub check_all_inputs {
	GetOptions(
	    'event=s'     => \$event,
	    'library=s'   => \$library,
	    'media_dir=s' => \$media_dir,
		'output_xml=s' => \$output_xml
	) or usage("Wrong arguments");

	# All arguments must be present
	usage ("Error: You must specify all arguments") if ( $library eq "" or $event eq "" or $media_dir eq "" or $output_xml eq "" );

	# The event name can't be blank
	usage ("Error: event name is required\n") if $event eq "";

	# The media_dir must be a directory
	usage( "media_dir \"$media_dir\" doesn't exist\n") unless -d $media_dir ;

	# The library must be a file and must end in .fcpbundle (which
	# we will remove because the importer doesn't want that)
	usage ("Library $library doesn't exist") unless -e $library;
	usage ("Library $library must end in .fcpbundle") unless $library =~ /\.fcpbundle$/;
	$library =~ s/\ /\%20/g;
	$library =~ s/\.fcpbundle$//g;
	
	usage ("ouptut_xml file must end in .fcpxml") unless $output_xml =~ /\.fcpxml$/;
	
}

sub usage {
	my $err = shift;
	print "Error: $err\n\n";
    my $p = $0;
    $p =~ s/.*\///g;
    print "Usage: $p <options>\n";
	print "Where options are as follows:\n";
	print "  --event=\"My New Event Name\"\n";
	print "  --library=\"/path/to/mylibrary.fcpbundle\"\n";
	print "  --media_dir=\"/path/to/Movies/iMovie/Events\"\n";
	print "  --output_xml=\"/tmp/output.fcpxml\"\n";
    exit 1;
}

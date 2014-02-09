#!/usr/bin/perl -w

#~/bin/HandBrakeCLI -i "iMovie Events/twain! (edited)/clip-2008-09-15 01;41;52.dv" -o test.mkv --preset "DV to MP4"
#!/bin/perl -w;
use strict;

use File::Find;
use File::Copy;
use File::Path qw(make_path);
use File::stat;
use Data::Dumper;
use Number::Bytes::Human qw(format_bytes);

#my $indir = "/Volumes/PatrickWD/iMovie Events";
my $indir = shift;

my @arr;
my $total_bytes = 0;
find( \&wanted, $indir );

my $count = $#arr + 1;
print $count . "\n";
my $iter = 1;
my $bytes_togo = $total_bytes;
while (my $entry = shift @arr ) {
	
	my $size = $$entry{'size'};
	
    print 	"$iter/$count (" . format_bytes($size) . 
			". " . format_bytes($bytes_togo) . 
			" remaining of " . format_bytes($total_bytes). ")\n";
    process_entry($entry);
	$bytes_togo -= $size;
	$iter++;
	
}

#######################
sub wanted {

    # only converting dv's
    return unless /\.dv$/i;

	#my $file = escapeshellarg($File::Find::name);

	my $dir =$File::Find::dir;
	if (!chdir($File::Find::dir)) {
		print "Couldn't change directory to $dir: $!\n";
		return;
	}
	
	my $size = -s $_;
	print "Size $_ - $size $!\n";
	print "Size $File::Find::dir - $size $!\n";
	$total_bytes += $size;
	if ($size == 0) {
		print "Skipping $_. 0 bytes.\n";
		return;
	}
	
    push(
        @arr,
        {
            name     => $_,
            dir      => $File::Find::dir,
            fullname => $File::Find::name,
			size	 => $size
        }
    );

}

sub escapeshellarg { 
    my ($str) = @_; # ? shift : $_;
    #$str =~ s/((?:^|[^\\])(?:\\\\)*)'/$1\\'/g;
    $str =~ s/\ /\\ /g;
    return "$str";
}


#######################
sub process_entry {
    my ($entry) = @_;

    #print Dumper($entry);
    #return 1;

    #    my $in = $File::Find::name;
    my $in = $$entry{'fullname'};

    #    my $out_file = $_;
    my $out_file = $$entry{'name'};
    $out_file =~ s/\.dv$/\.mov/i;

    #    my $idir = $File::Find::dir;
    #    my $odir = $File::Find::dir;

    my $idir = $$entry{'dir'};
    my $odir = $$entry{'dir'};
    $odir .= " (mov)";
    my $out = "$odir/$out_file";
    my $tmp = "/tmp/$out_file.$$";


    my $short_in = $in;
    $short_in =~ s/$indir//g;
    $short_in =~ s/^\///g;
    my $short_out = $out;
    $short_out =~ s/$indir//g;
    $short_out =~ s/^\///g;

    my $force = 0;
    if ( !-e $out || $force ) {
        print "Making $odir\n";
        make_path($odir);

        print "Converting $short_in $short_out\n";

        my $cmd =
"~/bin/HandBrakeCLI --verbose=0 -i \"$in\" -o \"$tmp\" --quality=22 --deinterlace=slower --encoder=x264 --loose-anamorphic";
        print "   " . $cmd . "\n";
        `$cmd >> /tmp/convert_log.txt 2>&1`;
        die "failed command $cmd\n" unless $? == 0;

		print "Copying $tmp to $out\n";
        move( $tmp, $out ) || die("failed mv of $tmp to $out");

        # Set file mtime and atime
		print "Updating timestamp\n";
        my $sb = stat($in);
        utime( $sb->atime, $sb->mtime, $out );
		print "Complete\n";

    }
    else {
        print "Skipping. Exists. $short_out\n";
    }
    print "\n\n\n";

}


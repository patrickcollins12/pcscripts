#!/opt/local/bin/perl -w

use strict;
use File::Find;
use Getopt::Long;

my %ignore = (
  'git' => qr{\/\.git\/},
  'img' => qr{\.(png|gif|jpg|svg|ttf|ico|psd)$}i,
  'js'  => qr{\.js(\.map)?$}i,
  'pyc'  => qr{\.(pyc|map|db|xlsx|jar|pdf)$}i,
  'css'  => qr{\.(css|less)$}i,
);

my $verbose;
my $js=0;
my $css=0;
my $pyc=0;
my $img=0;

GetOptions (
            "verbose"  => \$verbose,
            "js!" => \$js,
            "css!" => \$css,
            "pyc!" => \$pyc,
            "img!" => \$img,

            )   # flag
 or usage();

my $numargs = $#ARGV+1;
usage() if $numargs < 2;

my $pattern = shift;
find(\&wanted, @ARGV);

sub wanted {
    my $ff = $File::Find::name;
    return if -d;
    foreach my $k ( keys %ignore ) {
        my $v = $ignore{$k};
        
        # skip this ignore rule if includejs
        if ($k eq 'img' and $img) { next; };
        if ($k eq 'js' and $js) { next; };
        if ($k eq 'css' and $css) { next; };
        
        # print $v ."\n";
        if ($ff =~ $v ) {
            # print "Matched $ff. Skipping\n";
            return;
        }
    }
    # print "$File::Find::name\n";
    match_into($ff,$_);
}

sub match_into {
    my ($ff, $f) = @_;   
    
    my $fh;
    if (open($fh,"<", $f)) {
        my $printer = "\n$ff:\n";
        my $matched = 0;
        my $line = 1;
        while(<$fh>) {
            if (/$pattern/) {
                s/^\s+//g;
                $printer .= sprintf("line %5d: %s", $line, $_);
                $matched = 1;
            }
            $line++;
        }
        
        if ($matched) {
            print $printer;
        }
        
        close $fh;
    } else {
        print("Couldn't open $ff: $!");

        return;          
    }
}

sub usage{
    print STDERR "\nfindd.pl [--img] [--js] [--css] [--pyc]'pattern' <directories>\n\n   Try:\n    findd.pl 'TODO' .\n";
    exit;
}

#!/usr/bin/perl -w
use strict;
use File::Find;
my @dirs = @ARGV;
my %wanted;
find(\&wanted, @dirs);

my $count = scalar keys %wanted;
my $cnt;
foreach my $i ( keys %wanted ) {
   $cnt++;
   my $pct= sprintf("%0.2f", ($cnt/$count*100)); 
   my $o = $wanted{$i};
   my $cmd = "handbrakecli -i \"$i\" -o \"$o\" -b 2000 -e x264 -2 -d fast -w 768 -l 576 --denoise";
   print "$cnt/$count $cmd\n";
   #`$cmd > /dev/null 2>&1`;
   `$cmd`;
}

sub wanted {
   if ( /\.dv$/i ) {
      my $i = $File::Find::name;
      my $o = $i;
      $o =~ s/\.dv$/\.mp4/i;
      if (-e $o) {
         print "Skipping $o. Exists.\n";
      } else {
         $wanted{$i} = $o;
      }
   }
}

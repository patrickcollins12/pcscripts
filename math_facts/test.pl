#!/bin/perl
use strict;

my $num = 1242.0;

for (my $i=1; $i < $num/2; $i++) {
   my $div = $num / $i;
   if ($div == int($div)) {
      print "$num / $i = $div (1242)\n";
   }
}

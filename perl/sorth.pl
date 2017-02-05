#!/opt/local/bin/perl -w
# Usage: perl sorth.pl <col-to-sort> 
#    sorts on column 5 (default 0)
#    default separator is any whitespace
# e.g. du -ksh * | perl sorth.pl 0 
# e.g. ls -alrth | perl sorth.pl 5
# e.g. find . -type f -ls | perl sorth.pl 7

use strict;
my $sep = '\s';                  # Separate on whitespace
my $col = shift || 1; $col--;    # Sort on column 1 (array indexing)

my %bytes_multiplier = (
    'B' => 1, 'K' => 1024, 'M' => 1024*1024,
    'G' => 1024*1024*1024, 'T' => 1024*1024*1024*1024,
);
    
my ($line, %lines, %size);
while(<STDIN>){
    
    #store the line
    $lines{++$line} = $_; 
    
    s/^$sep*//g; s/$sep*$//g; #left and right trim
    
    my @a=split(qr{$sep+}); #split the string by the separator

    # Grab the 5th column, if it doesn't exist, make it 0
    my $amount = $a[$col] // 0; 

    # Match 123Mb or 12.3Gb and separate the parts
    if ( $amount =~ /(\-?[\d\.]+)([TGMKB]\w*)/i) { 
        $amount = $1;
        $amount *= $bytes_multiplier{uc($2)};        
    }

    # Store it for sorting
    $size{$line} = $amount // 0;
}

#sort by the multiplied amount and then print the original lines  
print $lines{$_} for sort { $size{$a} <=> $size{$b} } keys(%size);



use strict;

use XML::LibXML;
use File::Slurp;
my $file = shift;

my $xml = read_file($file);

#my $compiled_xpath = XML::LibXML::XPathExpression->new('//string');

#my $dom = XML::LibXML->load_xml(string => $xml);

my $parser = XML::LibXML->new();
my $doc    = $parser->parse_file($file);

my $query  = "//string";
my(@nodes)  = $doc->findnodes($query);

use Data::Dumper;
foreach my $i (@nodes) {
	print "$i\n";
}

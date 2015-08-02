#!/opt/local/bin/perl -w 
use strict;

use WWW::Mechanize;
use LWP::UserAgent;
use Data::Dumper;
use LWP::Debug qw(+);

my $url = "https://www.dropbox.com/login/";

my $ua = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.130 Safari/537.36';
my $mech = WWW::Mechanize->new(agent => $ua);

$mech->get( $url );

die "Can't even get the home page: ", $mech->response->status_line
    unless $mech->success;

$mech->submit_form(
    form_number => 0,
    fields      => {
        'login_email'    => 'pcollins@cpan.org',
        'login_password' => 'B3llSqui'
    }
);

print $mech->uri;

die "Can't even get the home page: ", $mech->response->status_line
    unless $mech->success;

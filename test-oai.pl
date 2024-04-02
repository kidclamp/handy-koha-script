#! /usr/bin/perl

use XML::Simple;
use LWP::UserAgent;
use HTTP::Request::Common;
use Data::Dumper;

my $base_url="https://ebs-suu.bywatersolutions.com/cgi-bin/koha/oai.pl?verb=ListRecords";
#my $extra = "&resumptionToken=marcxml/46650////0/0/158146";
my $url = "$base_url"."&metadataPrefix=marcxml";
my $ua = LWP::UserAgent->new();
while ( $url ){
    
    my $content = $ua->get($url, 'Accept-Encoding' => 'gzip,deflate');
    warn "could not retrieve $url" unless $content;
    warn "GOT URL: $url";
#warn Data::Dumper::Dumper( $content);
#warn Data::Dumper::Dumper( $content->decoded_content);
    my $xmlsimple = XML::Simple->new();
    my $result = $xmlsimple->XMLin($content->decoded_content);
#warn Data::Dumper::Dumper( $result );
#    foreach my $header ( @{$result->{ListRecords}->{record}} ){
#        warn $header->{header}->{identifier};
#    }
    my $token = $result->{ListRecords}->{resumptionToken}->{content};
    $url = $token ? 
        $base_url . "&resumptionToken=".$result->{ListRecords}->{resumptionToken}->{content}
        : undef ;
    warn "NEXT URL: $url";
}


#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese timethese/;
use Koha::Biblios;

my $biblio = Koha::Biblios->find( 25 );
my $record = $biblio->metadata->record;
my @items  = $biblio->items->as_list;

my $record_processor = Koha::RecordProcessor->new({
    filters => ['EmbedItems'],
    options => {
        interface => 'opac',
        items     => \@items
    }
});



cmpthese(
    -10,
    {
        noPassMSS => sub {
            $record_processor->process( $record, 0);
        },
        passMSS => sub {
            $record_processor->process( $record, 1);
        },
    }
);

#for ( my $i = 0 ; $i < 250 ; $i++ ) {
#    my $found = $hold->found;
#    my $wait = $found && $found eq 'W';
#}

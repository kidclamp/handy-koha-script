#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese timethese/;
use Koha::Biblios;

my $biblio = Koha::Biblios->find( 25 );
my $record = $biblio->metadata->record;
my @items  = $biblio->items->as_list;

my $item = Koha::Items->find(27);


cmpthese(
    -10,
    {
        is_de => sub {
            $item->is_denied_renewal;
        },
        may_de => sub {
            $item->maybe_denied_renewal;
        },
    }
);

#for ( my $i = 0 ; $i < 250 ; $i++ ) {
#    my $found = $hold->found;
#    my $wait = $found && $found eq 'W';
#}

#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese timethese/;
use Koha::Biblios;
use C4::XSLT qw(transformMARCXML4XSLT);

my $biblio0 = Koha::Biblios->find(44);
my $record0 = $biblio0->metadata->record;

my $biblio1 = Koha::Biblios->find(24);
my $record1 = $biblio1->metadata->record;

my $biblio10 = Koha::Biblios->find(40);
my $record10 = $biblio10->metadata->record;

my $biblio100 = Koha::Biblios->find(79);
my $record100 = $biblio100->metadata->record;

my $branches = { map { $_->branchcode => $_->branchname } Koha::Libraries->search({}, { order_by => 'branchname' })->as_list };
my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };

cmpthese(
    -10,
    {
        biblio0_pass => sub {
            transformMARCXML4XSLT($biblio0->biblionumber,$record0,undef,$branches,$itemtypes,undef);
        },
        biblio0_no => sub {
            transformMARCXML4XSLT($biblio0->biblionumber,$record0);
        },
        biblio1_pass => sub {
            transformMARCXML4XSLT($biblio1->biblionumber,$record1,undef,$branches,$itemtypes,undef);
        },
        biblio1_no => sub {
            transformMARCXML4XSLT($biblio1->biblionumber,$record1);
        },
        biblio10_pass => sub {
            transformMARCXML4XSLT($biblio10->biblionumber,$record10,undef,$branches,$itemtypes,undef);
        },
        biblio10_no => sub {
            transformMARCXML4XSLT($biblio10->biblionumber,$record10);
        },
        biblio100_pass => sub {
            transformMARCXML4XSLT($biblio100->biblionumber,$record100,undef,$branches,$itemtypes,undef);
        },
        biblio100_no => sub {
            transformMARCXML4XSLT($biblio100->biblionumber,$record100);
        },
    }
);

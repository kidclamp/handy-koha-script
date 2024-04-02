#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese timethese/;
use C4::Biblio qw(GetMarcSubfieldStructure TransformMarcToKoha TransformMarcXMLToKoha);
use Koha::Biblios;

my $biblio = Koha::Biblios->find(5);
my $record = $biblio->metadata->record;
my $xmlrecord = $biblio->metadata->metadata;
warn $xmlrecord;

GetMarcSubfieldStructure();
warn Data::Dumper::Dumper(            TransformMarcXMLToKoha({ xmlrecord => $xmlrecord, kohafields => undef }));

cmpthese(
    -10,
    {
        transform_xml_fields => sub {
#            TransformMarcToKoha( $record, "", 'no_items' );
            TransformMarcXMLToKoha({ xmlrecord => $xmlrecord, kohafields => ['biblio.title','biblioitems.copyrightdate'] });
        },
        transform_xml_reg => sub {
#            TransformMarcToKoha( $record, "", 'no_items' );
            TransformMarcXMLToKoha({ xmlrecord => $xmlrecord, kohafields => undef });
        },
        transform_reg => sub {
#            TransformMarcToKoha( $record, "" );
            TransformMarcToKoha({ record => $record });
        },
        transform_no_items => sub {
#            TransformMarcToKoha( $record, "", 'no_items' );
            TransformMarcToKoha({ record => $record, limit_table => 'no_items'});
        },
        transform_no_items_fields => sub {
#            TransformMarcToKoha( $record, "", 'no_items' );
            TransformMarcToKoha({ record => $record, kohafields => ['biblio.title','biblioitems.copyrightdate'], limit_table => 'no_items'});
        },
        transform_fields => sub {
#            TransformMarcToKoha( $record, "", 'no_items' );
            TransformMarcToKoha({ record => $record, kohafields => ['biblio.title','biblioitems.copyrightdate'] });
        },
    }
);

#!/usr/bin/env perl

use strict;
use warnings;


use t::lib::TestBuilder; 
use C4::Context;
use C4::ImportBatch;
use Koha::Plugins; 
use Module::Load::Conditional qw( can_load );
use Koha::DateUtils qw(dt_from_string);
use Koha::Biblios;
use DateTime;
use DateTime::Duration qw(delta_seconds);

my $batch_id = C4::ImportBatch::AddImportBatch({
    record_type => 'biblio',
    file_name => 'charles',
    comments => 'test',
    import_status => 'staging'
});


my $builder = t::lib::TestBuilder->new;
my $biblio = $builder->build_sample_biblio();
$biblio = Koha::Biblios->find(48);
my $record = $biblio->metadata->record();
$record->append_fields( MARC::Field->new('952', '', '', 'a' => "CPL" ) );
my $marc = $record->as_usmarc;
my $marcxml = $record->as_xml("MARC21");
my $count =1 ;
my $time0 = dt_from_string;
my $time2;
my $diff = $time0->subtract_datetime_absolute($time0);
while( $diff->delta_seconds < 2 ){
my $record = $record->clone;
my $time1 = dt_from_string;
my $import_record_id = C4::ImportBatch::AddBiblioToBatch( $batch_id, $count,$record,'UTF8',1);
my @import_items_ids = C4::ImportBatch::AddItemsToImportBiblio( $batch_id, $import_record_id, $record, 0);
$time2 = dt_from_string;
my $diff =  $time1->subtract_datetime_absolute($time2);
warn "++++++++++++Added record $count ++++++++++++++++" if $diff->delta_seconds > 0;
$count++
}
my $diff = $time0->delta_ms($time2);
warn Data::Dumper::Dumper( $diff->delta_seconds );

#my $dbh = C4::Context->dbh;
#$dbh->do("
#    INSERT INTO import_records (import_batch_id, marc, marcxml, marcxml_old, record_type) VALUES ($batch_id,$marc,$marcxml,$marcxml,'biblio')
#");


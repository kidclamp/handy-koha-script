#! /usr/bin/perl
use t::lib::TestBuilder;
use Koha::Libraries;
use Koha::Holds;
use Koha::Patrons;
use Koha::DateUtils qw( dt_from_string output_pref );


my @branchcodes = Koha::Libraries->search()->get_column('branchcode');
my @itypes = Koha::ItemTypes->search()->get_column('itemtype');
my @ccodes = Koha::AuthorisedValues->search( { category => 'ccode' } )->get_column('authorised_value');
my @locations = Koha::AuthorisedValues->search( { category => 'LOC' } )->get_column('authorised_value');
my @notforloans = Koha::AuthorisedValues->search( { category => 'NOT_LOAN' } )->get_column('authorised_value');
my @damaged = Koha::AuthorisedValues->search( { category => 'DAMAGED' } )->get_column('authorised_value');
my @withdrawn = Koha::AuthorisedValues->search( { category => 'WITHDRAWN' } )->get_column('authorised_value');
push @withdrawn, 0;
push @damaged, 0;
push @notforloans, 0;
my @callnumbers = ('FIC','NF','J','YA');
my $patrons = Koha::Patrons->search({});
my $builder = t::lib::TestBuilder->new(); 

while( my $patron = $patrons->next) {
    my $several = 10;#int( rand(10) ) * 10;
    for( my $i = 0; $i < $several; $i++ ){
        my $branchcode = $branchcodes[rand @branchcodes ];
        my $days_staged    =  int( rand(10) );
        my $days_pickups   = int( rand(10) );
        my $days_arrival   = int( rand(10) );
        my $days_delivered = int( rand(10) );
        my $staged = int( rand() * 2 );
        my $arrived = $staged && int( rand() * 2);
        my $deliverd = $arrived && int( rand() * 2);
        my $date_time = dt_from_string()->set_hour( int( rand(24) ) )->set_minute( int( rand(60) ) );
        my $curbside = $builder->build_object({class=> 'Koha::CurbsidePickups', value => {
            borrowernumber => $patron->id,
            branchcode => $branchcode,
            scheduled_pickup_datetime => $date_time->add( days => $days_pickups),
            arrival_datetime => $arrived ? Koha::DateUtils::dt_from_string()->add( days => $days_arrival) : undef,
            delivered_datetime => $delivered ? Koha::DateUtils::dt_from_string()->add( days => $days_delivered) : undef,
            staged_datetime => $staged ? Koha::DateUtils::dt_from_string()->add( days => $days_staged) : undef,
            staged_by => ($staged || $arrived || $delivered) ? int( rand(50) ) + 1 : undef,
        }});
    }
}

1;

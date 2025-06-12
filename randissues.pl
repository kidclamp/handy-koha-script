#! /usr/bin/perl
use Modern::Perl;
use Getopt::Long;

use t::lib::TestBuilder;
use Koha::Libraries;
use Koha::Holds;
use Koha::Patrons;
use Koha::DateUtils qw(dt_from_string);

my $patron;
GetOptions(
    "p|patron" => \$patron,
);

my $libraries = Koha::Libraries->search();
my $builder = t::lib::TestBuilder->new(); 
my @statuses = ('ASKED', 'CHECKED', 'ACCEPTED', 'REJECTED', 'ORDERED', 'AVAILABLE');

my $one_borrower;
$one_borrower = Koha::Patrons->find( $patron ) if $patron;

while( my $library = $libraries->next) {
    my $several = int( rand(10) )+10;
    for( my $i = 0; $i < $several; $i++ ){
        my $borrower = $one_borrower || Koha::Patrons->find(int(rand(50))+1 );
        #my $biblio = Koha::Biblios->find(30);#int(rand(432))+1 );
        my $item = Koha::Items->search({},{ order_by => \["rand()"] })->next;
        warn $item->id;
        next unless $item;
        my $date_due = dt_from_string()->add_duration( DateTime::Duration->new( days => -2, minutes => 1 ) );
        my $itemnumber = $item->id;# && int( rand(2) ) ? $item->itemnumber : undef;
        my $issue = $builder->build_object({
            class => "Koha::Checkouts",
            value => {
                borrowernumber => $borrower->borrowernumber,
                issuer_id      => 19,
                itemnumber => $itemnumber,
                issuedate => dt_from_string(),
                date_due  => $date_due,
                onsite_checkout => 0,
                auto_renew      => 1,
                auto_renew_error => undef,
                renewals_count => 0,
                unseen_renewals => 0,
                returndate => undef,
                branchcode  => $library->branchcode,
            }
        });
    }
}

1;

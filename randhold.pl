#! /usr/bin/perl
use t::lib::TestBuilder;
use Koha::Libraries;
use Koha::Holds;
use Koha::Patrons;
use Koha::DateUtils qw(dt_from_string);

use Getopt::Long;
use Modern::Perl;

my $biblionumber;
my $borrowernumber;
my $count;

GetOptions(
    "b|biblionumber=i" => \$biblionumber,
    "p|patron=i" => \$borrowernumber,
    "n|number=i" => \$count,
);

$count //= 10;
my $biblio_params = {};
my $borrower_params = {};
$biblio_params->{biblionumber} = $biblionumber if $biblionumber;
$borrower_params->{borrowernumber} = $borrowernumber if $borrowernumber;

my $libraries = Koha::Libraries->search();
my $builder = t::lib::TestBuilder->new(); 

while( my $library = $libraries->next) {
    my $several = int( rand($count) )+10;
    for( my $i = 0; $i < $several; $i++ ){
        my $holder = Koha::Patrons->search($borrower_params,{'order_by'=>\"rand()"})->next;
        my $biblio = Koha::Biblios->search($biblio_params,{'order_by'=>\"rand()"})->next;
        next unless $biblio;
        my $item = $biblio->items->search({},{ order_by => \["rand()"] })->next;
        # Below is to set a 50/50 chance of creating an item level versus next available hold
        my $itemnumber = $item && int( rand(2) ) ? $item->itemnumber : undef;
        my $hold = $builder->build_object({
            class => "Koha::Holds",
            value => {
                borrowernumber => $holder->borrowernumber,
                biblionumber => $biblio->biblionumber,
                reservedate => dt_from_string(),
                branchcode  => $library->branchcode,
                desk_id => undef,
                cancellationdate => undef,
                cancellation_reason => undef,
                priority => $biblio->holds->count()+1,
                found => undef,
                itemnumber => $itemnumber,
                waitingdate => undef,
                expirationdate => undef,
                suspend => 0,
                suspend_until=>undef,
                item_level_hold => $itemnumber ? 1 : 0,
                itemtype => undef,
                patron_expiration_date => undef,
            }
        });
    }
}

1;

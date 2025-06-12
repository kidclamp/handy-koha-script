#! /usr/bin/perl
use t::lib::TestBuilder;
use Koha::Libraries;
use Koha::Holds;
use Koha::Old::Holds;
use Koha::Patrons;
use Koha::DateUtils qw(dt_from_string);


my $libraries = Koha::Libraries->search();
my $builder = t::lib::TestBuilder->new(); 
my @found = ('W','F',undef);

while( my $library = $libraries->next) {
    my $several = int( rand(10) )+10;
    for( my $i = 0; $i < $several; $i++ ){
        my $holder = Koha::Patrons->find(int(rand(50))+1 );
        my $biblio = Koha::Biblios->find(312);#int(rand(432))+1 );
        my $found = $found[ rand @found ];
        next unless $biblio;
        my $item = $biblio->items->search({},{ order_by => \["rand()"] })->next;
        my $itemnumber = $item && int( rand(2) ) ? $item->itemnumber : undef;
        my $hold = $builder->build_object({
            class => "Koha::Old::Holds",
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

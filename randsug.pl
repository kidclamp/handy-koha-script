#! /usr/bin/perl
use t::lib::TestBuilder;
use Koha::Libraries;
use Koha::Suggestions;
use Koha::Patrons;


my $libraries = Koha::Libraries->search();
my $builder = t::lib::TestBuilder->new(); 
my @statuses = ('ASKED', 'CHECKED', 'ACCEPTED', 'REJECTED', 'ORDERED', 'AVAILABLE');

while( my $library = $libraries->next) {
    my $several = int( rand(10) );
    for( my $i = 0; $i < $several; $i++ ){
        my $suggester = Koha::Patrons->find( int(rand(50))+1 );
        $builder->build_object({
            class => "Koha::Suggestions",
            value => {
                suggestedby => $suggester->borrowernumber,
                suggesteddate => '2021-01-01',
                managedby => undef,
                acceptedby => undef,
                manageddate => undef,
                accepteddate => undef,
                rejectedby => undef,
                rejecteddate => undef,
                lastmodificationby => undef,
                archived => 0,
                STATUS => $statuses[ rand @statuses],
                branchcode => $library->branchcode,
                biblionumber => undef,
                budgetid => 1
            }
        });
    }
}

1;

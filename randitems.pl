#! /usr/bin/perl
use t::lib::TestBuilder;
use Koha::Libraries;
use Koha::Holds;
use Koha::Patrons;
use Koha::DateUtils;


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
my $biblios = Koha::Biblios->search({biblionumber=>3});
my $builder = t::lib::TestBuilder->new(); 

while( my $biblio = $biblios->next) {
    my $several = 150;#int( rand(10) ) * 10;
    for( my $i = 0; $i < $several; $i++ ){
        my $dewey = $i%2 ? " ".int(rand(1000))." " : " " ;
        my $call = $callnumbers[rand @callnumbers] . "$dewey" . substr($biblio->author,0,3);
        my $homelibrary = $branchcodes[rand @branchcodes ];
        my $holdlibrary = $branchcodes[rand @branchcodes ];
        my $item = $builder->build_sample_item({
                library => $homelibrary, #Without this we create a new library everytime
                homebranch => $homelibrary,
                holdingbranch => $holdlibrary,
                biblionumber => $biblio->biblionumber,
                itype => $itypes[rand @itypes ],
                notforloan => $notforloans[rand @notforloans],
                location => $locations[rand @locations],
                ccode => $ccodes[rand @ccodes],
                damaged => $damaged[rand @damaged],
                withdrawn => $withdrawn[rand @withdrawn],
                itemcallnumber => $call
        });
    }
}

1;

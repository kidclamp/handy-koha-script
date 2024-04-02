use Modern::Perl;

use Koha::Patrons;
use t::lib::TestBuilder;
use Koha::Libraries;



my @branchcodes = Koha::Libraries->search()->get_column('branchcode');
my @categories = Koha::Patron::Categories->search()->get_column('categorycode');


my $card = Koha::Patrons->search({ cardnumber => { "like", "2%" }})->_resultset->get_column("cardnumber")->max;

my $created = 0;
my $builder = t::lib::TestBuilder->new();
while( $created < 100000 ){
    $card++;
    my $patron = $builder->build({ source => "Borrower", value =>{
            branchcode => $branchcodes[ rand @branchcodes],
            categorycode => $categories[ rand @categories ],
            sms_provider_id => undef,
            cardnumber => $card,

        }
    });
    $created++;
}
$created = 1000;
my @total;
while( $created < 100 ){
    $card++;
    my $patron = $builder->build_object({ class => "Koha::Patrons", value =>{
            branchcode => $branchcodes[ rand @branchcodes],
            categorycode => $categories[ rand @categories ],
            sms_provider_id => undef,
            cardnumber => $card,

        }
    });
    push @total, $patron->unblessed;
    $created++;
}
Koha::Patrons->_resultset->populate(\@total) if scalar @total;


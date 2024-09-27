use Modern::Perl;

use Koha::Patrons;

my $patrons = Koha::Patrons->search({ cardnumber => { '!=' => undef } },{ order_by => \"rand()" });

print $patrons->next->cardnumber . "\n" for 0..10;


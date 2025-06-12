use Modern::Perl;

use Koha::Items;

my $items = Koha::Items->search({ barcode => { '!=' => undef } },{ order_by => \"rand()" });

print $items->next->barcode . "\n" for 0..100;


#!/usr/bin/perl

use Koha::Patrons;
use Koha::Items;

my $patron = Koha::Patrons->find({cardnumber=>23529001000463});
$patron->userid("enda")->store;
$patron->set_password({password=>"acosta"});

$patron = Koha::Patrons->find({cardnumber=>23529000035676});
$patron->userid("henry")->store;
$patron->set_password({password=>"ace"});

$patron = Koha::Patrons->find({cardnumber=>23529000050113});
$patron->userid("jordan")->store;
$patron->set_password({password=>"alford"});

$patron = Koha::Patrons->find({cardnumber=>23529000139858});
$patron->userid("ronnie")->store;
$patron->set_password({password=>"ballard"});

for( my $i = 1; $i<=10; $i++ ){
    Koha::Item->new({
        barcode => "CHESS$i",
        biblionumber => "2",
        biblioitemnumber => "2",
        homebranch=>'CPL',
        holdingbranch=>'CPL',
        itype => 'BK'
        })->store;
}

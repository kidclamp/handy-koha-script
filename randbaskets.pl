#! /usr/bin/perl
use t::lib::TestBuilder;
use Koha::Libraries;
use Koha::Holds;
use Koha::Patrons;
use Koha::DateUtils qw(dt_from_string);


my $libraries = Koha::Libraries->search();
my $builder = t::lib::TestBuilder->new(); 
my @statuses = ('ASKED', 'CHECKED', 'ACCEPTED', 'REJECTED', 'ORDERED', 'AVAILABLE');

my $several = 500;#int( rand(500) )+10;
for( my $i = 0; $i < $several; $i++ ){
    my $vendor = $builder->build_object({ class => "Koha::Acquisition::Booksellers",
        value => {
            deliverytime => 1
        }
    });
    my $basket = $builder->build_object({ class => "Koha::Acquisition::Baskets",
        value => {
            contractnumber=>undef,
            basketgroupid=>undef,
            branch=>undef,
            booksellerid => $vendor->id
        }
    });
    my $several_o = 0;#int( rand(10) )+10;
    for( my $k = 0; $k < $several_o; $k++ ){ 
        my $orders = $builder->build_object({
            class => "Koha::Acquisition::Orders",
            value => {
                basketno => $basket->id,
                datereceived => undef,
                datecancellationprinted => undef,
                cancellationreason => undef,
                subscriptionid=>undef,
                invoiceid => undef,
            }
        });
    }
}

1;

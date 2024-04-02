#! /usr/bin/perl
use t::lib::TestBuilder;
use Koha::Libraries;
use Koha::Holds;
use Koha::Patrons;
use Koha::DateUtils qw(dt_from_string);


my $libraries = Koha::Libraries->search();
my $builder = t::lib::TestBuilder->new(); 

my $several = 500;#int( rand(500) )+10;
for( my $i = 0; $i < $several; $i++ ){
    my $vendor = $builder->build_object({ class => "Koha::Acquisition::Booksellers",
        value => {
        }
    });
}

1;

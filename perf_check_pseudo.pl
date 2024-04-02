#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese timethese/;

use C4::Circulation qw( AddIssue AddReturn );

use t::lib::TestBuilder;
use t::lib::Mocks;



my $builder = t::lib::TestBuilder->new;


my $schema = Koha::Database->new->schema;
my $patron =$builder->build_object( { class => 'Koha::Patrons' } )->store();
my $item =$builder->build_sample_item();

$schema->storage->txn_begin;

t::lib::Mocks::mock_userenv({ branchcode => $item->homebranch  });
t::lib::Mocks::mock_preference('Pseudonymization', '0');
t::lib::Mocks::mock_preference('PseudonymizationPatronFields', '');
t::lib::Mocks::mock_preference('PseudonymizationTransactionFields', '');


warn "Pseudonymization Disabled";
issue_return();

$schema->storage->txn_rollback;
$schema->storage->txn_begin;
t::lib::Mocks::mock_preference('Pseudonymization', '1');
warn "Pseudonymization Enabled, no fields";
issue_return();

$schema->storage->txn_rollback;
$schema->storage->txn_begin;
t::lib::Mocks::mock_preference('PseudonymizationPatronFields', 'city,country,dateenrolled,categorycode,sex,branchcode,title,sort1,sort2,state,zipcode');
warn "Pseudonymization enabled with all patron fields";
issue_return();

$schema->storage->txn_rollback;
$schema->storage->txn_begin;
t::lib::Mocks::mock_preference('PseudonymizationTransactionFields', 'ccode,datetime,holdingbranch,homebranch,itemtype,itemcallnumber,itemnumber,transaction_branchcode,location,transaction_type');
warn "Pseudonymization enabled with all patron and transaction fields";
issue_return();

$schema->storage->txn_rollback;

my $attr_type = $builder->build_object({ class => 'Koha::Patron::Attribute::Types', value => { keep_for_pseudonymization => 1 } })->store();
my $attribute = $builder->build_object({ class => 'Koha::Patron::Attributes', value => { code => $attr_type->code, borrowernumber => $patron->id }} )->store();

$schema->storage->txn_begin;
t::lib::Mocks::mock_preference('PseudonymizationTransactionFields', 'ccode,datetime,holdingbranch,homebranch,itemtype,itemcallnumber,itemnumber,transaction_branchcode,location,transaction_type');
warn "Pseudonymization enabled with all patron and transaction fields and an attribute";
issue_return();

$schema->storage->txn_rollback;

$builder->build_object({ class => 'Koha::Patron::Attribute::Types', value => { keep_for_pseudonymization => 1 } })->store();
$builder->build_object({ class => 'Koha::Patron::Attribute::Types', value => { keep_for_pseudonymization => 1 } })->store();
$builder->build_object({ class => 'Koha::Patron::Attribute::Types', value => { keep_for_pseudonymization => 1 } })->store();
$builder->build_object({ class => 'Koha::Patron::Attribute::Types', value => { keep_for_pseudonymization => 1 } })->store();
$builder->build_object({ class => 'Koha::Patron::Attribute::Types', value => { keep_for_pseudonymization => 1 } })->store();

$schema->storage->txn_begin;
t::lib::Mocks::mock_preference('PseudonymizationTransactionFields', 'ccode,datetime,holdingbranch,homebranch,itemtype,itemcallnumber,itemnumber,transaction_branchcode,location,transaction_type');
warn "Pseudonymization enabled with all patron and transaction fields and an attribute with more types existing";
issue_return();

$schema->storage->txn_rollback;
sub issue_return {
    cmpthese(
        -10,
        {
            issue => sub {

                $builder->build_object( { class => 'Koha::Statistics', value => { type => 'issue', borrowernumber=> $patron->id, itemnumber => $item->id  } } )->store();

            },
            return => sub {
                $builder->build_object( { class => 'Koha::Statistics', value => { type => 'return', borrowernumber => $patron->id, itemnumber => $item->id } } )->store();
            },
            checkout_in => sub {
                AddIssue( $patron, $item->barcode );
                AddReturn( $item->barcode, $item->homebranch );
            },
        }
    );
}


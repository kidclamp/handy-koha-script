## Please see file perltidy.ERR
use Koha::Biblios;
use C4::Circulation qw/AddIssue CanBookBeRenewed/;
use t::lib::TestBuilder;
use t::lib::Mocks;
use Koha::CirculationRules;
use Koha::Patrons;
use C4::Reserves qw/AddReserve ItemsAnyAvailableAndNotRestricted/;
use Benchmark qw/cmpthese timethese/;
use Carp::Always;

            my $builder = t::lib::TestBuilder->new;
            my $library = $builder->build(
                {
                    source => 'Branch',
                }
            );
            my $library2 = $builder->build(
                {
                    source => 'Branch',
                }
            );

            my $patron_category = $builder->build(
                {
                    source => 'Category',
                    value  => {
                        category_type => 'P',
                        enrolmentfee  => 0,
                        BlockExpiredPatronOpacActions =>
                          -1,    # Pick the pref value
                    }
                }
            );
            t::lib::Mocks::mock_userenv(
                { branchcode => $library2->{branchcode} } );

cmpthese(
    -100,
    {
        checkrenew => sub {

            t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable',
                1 );


            #Can only reserve from home branch
            Koha::CirculationRules->set_rule(
                {
                    branchcode => undef,
                    itemtype   => undef,
                    rule_name  => 'holdallowed',
                    rule_value => 1
                }
            );
            Koha::CirculationRules->set_rule(
                {
                    branchcode   => undef,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'onshelfholds',
                    rule_value   => 1
                }
            );

            my $biblio = $builder->build_sample_biblio();
            my $item_1 = $builder->build_sample_item(
                {
                    biblionumber => $biblio->biblionumber,
                    library      => $library2->{branchcode},
                }
            );
            my $item_2 = $builder->build_sample_item(
                {
                    biblionumber => $biblio->biblionumber,
                    library      => $library2->{branchcode},
                    itype        => $item_1->effective_itemtype,
                }
            );

            Koha::CirculationRules->set_rules(
                {
                    categorycode => undef,
                    itemtype     => $item_1->effective_itemtype,
                    branchcode   => undef,
                    rules        => {
                        reservesallowed  => 25,
                        holds_per_record => 25,
                        issuelength      => 14,
                        lengthunit       => 'days',
                        renewalsallowed  => 1,
                        renewalperiod    => 7,
                        norenewalbefore  => undef,
                        auto_renew       => 0,
                        fine             => .10,
                        chargeperiod     => 1,
                        maxissueqty      => 20
                    }
                }
            );

            my $borrowernumber1 = Koha::Patron->new(
                {
                    firstname    => 'Kyle',
                    surname      => 'Hall',
                    categorycode => $patron_category->{categorycode},
                    branchcode   => $library2->{branchcode},
                }
            )->store->borrowernumber;
            my $borrowernumber2 = Koha::Patron->new(
                {
                    firstname    => 'Chelsea',
                    surname      => 'Hall',
                    categorycode => $patron_category->{categorycode},
                    branchcode   => $library2->{branchcode},
                }
            )->store->borrowernumber;
            my $patron_category_2 = $builder->build(
                {
                    source => 'Category',
                    value  => {
                        category_type => 'P',
                        enrolmentfee  => 0,
                        BlockExpiredPatronOpacActions =>
                          -1,    # Pick the pref value
                    }
                }
            );
            my $borrowernumber3 = Koha::Patron->new(
                {
                    firstname    => 'Carnegie',
                    surname      => 'Hall',
                    categorycode => $patron_category_2->{categorycode},
                    branchcode   => $library2->{branchcode},
                }
            )->store->borrowernumber;

            my $borrower1 = Koha::Patrons->find($borrowernumber1)->unblessed;
            my $borrower2 = Koha::Patrons->find($borrowernumber2)->unblessed;

            my $issue = AddIssue( $borrower1, $item_1->barcode );

            my ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            AddReserve(
                {
                    branchcode     => $library2->{branchcode},
                    borrowernumber => $borrowernumber2,
                    biblionumber   => $biblio->biblionumber,
                    priority       => 1,
                }
            );

            Koha::CirculationRules->set_rules(
                {
                    categorycode => undef,
                    itemtype     => $item_1->effective_itemtype,
                    branchcode   => undef,
                    rules        => {
                        onshelfholds => 0,
                    }
                }
            );
            t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable',
                0 );
            ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable',
                1 );
            ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            Koha::CirculationRules->set_rules(
                {
                    categorycode => undef,
                    itemtype     => $item_1->effective_itemtype,
                    branchcode   => undef,
                    rules        => {
                        onshelfholds => 1,
                    }
                }
            );
            t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable',
                0 );
            ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            t::lib::Mocks::mock_preference( 'AllowRenewalIfOtherItemsAvailable',
                1 );
            ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            AddReserve(
                {
                    branchcode     => $library2->{branchcode},
                    borrowernumber => $borrowernumber3,
                    biblionumber   => $biblio->biblionumber,
                    priority       => 1,
                }
            );

            ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            my $item_3 = $builder->build_sample_item(
                {
                    biblionumber => $biblio->biblionumber,
                    library      => $library2->{branchcode},
                    itype        => $item_1->effective_itemtype,
                }
            );

            ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            Koha::CirculationRules->set_rules(
                {
                    categorycode => $patron_category_2->{categorycode},
                    itemtype     => $item_1->effective_itemtype,
                    branchcode   => undef,
                    rules        => {
                        reservesallowed => 0,
                    }
                }
            );

            ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            Koha::CirculationRules->set_rules(
                {
                    categorycode => $patron_category_2->{categorycode},
                    itemtype     => $item_1->effective_itemtype,
                    branchcode   => undef,
                    rules        => {
                        reservesallowed => 25,
                    }
                }
            );

            # Setting item not checked out to be not for loan but holdable
            $item_2->notforloan(-1)->store;

            ( $renewokay, $error ) =
              CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            my $mock_circ = Test::MockModule->new("C4::Circulation");
            $mock_circ->mock(
                CanItemBeReserved => sub {
                    warn "Checked";
                    return { status => 'no' };
                }
            );

            $item_2->notforloan(0)->store;
            $item_3->delete();

          # Two items total, one item available, one issued, two holds on record

            CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );

            $item_3 = $builder->build_sample_item(
                {
                    biblionumber => $biblio->biblionumber,
                    library      => $library2->{branchcode},
                    itype        => $item_1->effective_itemtype,
                }
            );

            Koha::CirculationRules->set_rules(
                {
                    categorycode => undef,
                    itemtype     => $item_1->effective_itemtype,
                    branchcode   => undef,
                    rules        => {
                        reservesallowed => 0,
                    }
                }
            );
            CanBookBeRenewed( $borrowernumber1, $item_1->itemnumber );
        }
    }
);

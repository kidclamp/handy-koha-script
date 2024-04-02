use C4::Reserves;
use Koha::Libraries;
use Koha::Biblios;
use Koha::Patrons;

use Koha::Holds;
use KOha::Old::Holds;
use Koha::Checkouts;
use Koha::Old::Checkouts;

print "Enter a borrowernumber: ";
my $cardnumber = <>;
chop( $cardnumber );
while ( $cardnumber ){
    print "\n";
    my $patron = Koha::Patrons->find({ cardnumber => $cardnumber });
    die "Not found" unless $patron;
    warn "Found ".$patron->surname.", ".$patron->firstname;
    print "\nEnter pickup branchcode: ";
    my $branchcode = <>;
    chop($branchcode);
    my $branch = Koha::Libraries->find({ branchcode => $branchcode });
    die "Branch not found" unless $branch;
    print "\nEnter a biblionumber: ";
    my $biblionumber = <>;
    chop($biblionumber);
    while ( $biblionumber ){
        print  "\n";
        my $biblio = Koha::Biblios->find($biblionumber);
        die "No biblio found" unless $biblio;
        warn "Found biblio: ".$biblio->title;
        my $had = Koha::Old::Checkouts->search({
            issuedate => {
                ">" =>"2022-03-26"
            }, 
            "item.biblionumber" => $biblionumber
        }, {join => 'item'});
        my $has = Koha::Checkouts->search({
            issuedate => {
                ">" =>"2022-03-26"
            }, 
            "item.biblionumber" => $biblionumber
        }, {join => 'item'});
        my $had_reserve = Koha::Old::Holds->search({
            reservdate => { ">" => "2022-03-26" },
            biblionumber => $biblionumber,
            itemnumebr => undef
        });
        my $has_reserve = Koha::Holds->search({
            reservdate => { ">" => "2022-03-26" },
            biblionumber => $biblionumber,
            itemnumebr => undef
        });
        warn "is borrowing" if $has->count > 0;
        warn "has borrowed" if $had->count > 0;
        warn "had reserved" if $had_reserve->count > 0;
        warn "has reserved" if $has_reserve->count > 0;
        unless ( $has->count > 0 || $had->count > 0 || $had_reserve->count > 0 || $has_reserve->count > 0 ){
            my $reserve = C4::Reserves::AddReserve({
                borrowernumber => $patron->borrowernumber,
                biblionumber => $biblionumber,
                reservation_date => "2022-03-26",
                branchcode => $branchcode
            });
            warn "Reserve placed with id ".$reserve;
        }
        print "Another bib: ";
        $biblionumber = <>;
        chop($biblionumber);
    }
    print "Another cardnumber: ";
    $cardnumber = <>;
    chop($cardnumber);
}


#! /usr/bin/perl

use Getopt::Long;

use C4::Context;
use C4::Installer;

my (
    $sth,
    $query,
    $table,
    $type,
);

my $schema = Koha::Database->new()->schema();

my ( $silent, $force );
GetOptions(
    'update=s' => \@updates,
);
my $dbh = C4::Context->dbh;


my $db_revs_dir = C4::Context->config('intranetdir') . '/installer/data/mysql/db_revs';

my @files;
foreach $update (@updates){
    push @files, sprintf( "%s/%s", $db_revs_dir, $update );
}
warn Data::Dumper::Dumper @files;

my $report = update( \@files);
warn Data::Dumper::Dumper( $report );

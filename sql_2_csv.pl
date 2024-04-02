#! /usr/bin/perl

use DBI;
use C4::Context;
use Modern::Perl;
use Text::CSV;
use Encode qw( decode );


my $name = $ARGV[0];
my $query = $ARGV[1];

my $dbh = C4::Context->dbh;

my $sth = $dbh->prepare( $query );
$sth->execute() or die $DBI::errstr;

my $csv = Text::CSV->new({
    binary      => 1,
    quote_char  => '"',
    sep_char    => ',',
    eol         => "\r\n"
    });

my $filename = "$name".".csv";
my $filehandle;
open $filehandle, ">", $filename or die "unable to open $filename: $!";

my @fields = map { decode( 'utf8', $_ ) } @{ $sth->{NAME} };

$csv->print($filehandle, \@fields );

while (my @row = $sth->fetchrow_array()) {
    $csv->print( $filehandle, \@row);
}
$filehandle->close;

#! /usr/bin/perl

use Modern::Perl;
use Text::CSV qw(csv);
use File::Slurp;

use Koha::Patron::Attribute::Types;
use Koha::Libraries;
use Koha::Patron::Categories;

my @branchcodes = Koha::Libraries->search()->get_column('branchcode');
my @categories = Koha::Patron::Categories->search()->get_column('categorycode');
my @grades = (1,2,3,4,5,6,7,8,9,10,11,12,"pre-k",'college',"library school",'');
my @schools = ('harvard','yale','dartmouht','hogwarts','trade','CCV','NYU','Oxford','Cambridge','Eaton','');
my @internet = (1,0);
my @codes = (1,0);

my @surnames = read_file("surnames.txt", chomp => 1);
my @firstnames = read_file("firstnames.txt", chomp => 1);


my $csv = Text::CSV->new({
    binary      => 1,
    quote_char  => '"',
    sep_char    => ',',
    eol         => "\r\n"
    });

my $filename = "patron_import.csv";
my $filehandle;
open $filehandle, ">", $filename or die "unable to open $filename: $!";

$csv->print($filehandle,["surname","firstname",'branchcode','categorycode','patron_attributes']);


my $several = 100000;
for( my $i = 0; $i < $several; $i++ ){
    my $branchcode = $branchcodes[rand @branchcodes ];
    my $category = $categories[rand @categories ];
    my $firstname = $firstnames[rand @firstnames ];
    my $surname = $surnames[rand @surnames ];
    my $grade = $grades[rand @grades];
    my $school = $schools[rand @schools];
    my $int_p = $internet[rand @internet];
    my $coder = $codes[rand @codes];

    $csv->print($filehandle,[$surname,$firstname,$branchcode,$category,"GRADE:$grade,SCHOOLID:$school,INTERNET:$int_p,CODE:$coder"]);
}

close $filehandle or die "failed to close $filename: $!";


foreach my $code ('GRADE','SCHOOLID','INTERNET','CODE'){
    my $type = Koha::Patron::Attribute::Types->find({ code => $code });
    Koha::Patron::Attribute::Type->new({
        code => $code,
        description => 'Test',
        staff_searchable => 1
    })->store unless $type;
}

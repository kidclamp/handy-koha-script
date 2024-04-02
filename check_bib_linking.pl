#! /usr/bin/perl
use MARC::Field;
use C4::Heading;
use C4::Context;
use Koha::Biblios;
use Module::Load::Conditional qw(can_load);
use Getopt::Long;

my $biblionumber;
GetOptions(
    "b|biblionumber=s" => \$biblionumber
);

warn "Using linker ".C4::Context->preference("LinkerModule");
warn "Options " . C4::Context->preference("LinkerOptions");

my $linker_module =
  "C4::Linker::" . ( C4::Context->preference("LinkerModule") || 'Default' );
unless ( can_load( modules => { $linker_module => undef } ) ) {
    $linker_module = 'C4::Linker::Default';
    unless ( can_load( modules => { $linker_module => undef } ) ) {
        die "Unable to load linker module. Aborting.";
    }
}

my $linker = $linker_module->new(
    {
        'options'    => C4::Context->preference("LinkerOptions")
    }
);

#my $bib = GetMarcBiblio({ biblionumber=>$biblionumber,embed_items=>1});
my $biblio = Koha::Biblios->find( $biblionumber );
die "Can't find that" unless $biblio;
my $record = $biblio->metadata->record();

    foreach my $field ( $record->fields() ) {
        warn "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++";
        my $heading = C4::Heading->new_from_field( $field, $frameworkcode );
        warn $field->tag() . ( $heading ? " is a linkable field" : " is not linkable");
        next unless defined $heading;

        # check existing $9
        my $current_link = $field->subfield('9');
        warn "Currently linked to $current_link" if $current_link;

        warn "Searching for " . $heading->search_form();
        warn "Found :";
        warn Data::Dumper::Dumper( $heading->authorities );

        my ( $authid, $fuzzy, $match_count ) = $linker->get_link($heading);

        warn "We found $authid, and matched $match_count";
        warn "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++";
    }
1;


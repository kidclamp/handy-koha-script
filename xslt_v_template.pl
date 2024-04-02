#!/usr/bin/env perl

use strict;
use warnings;

use Benchmark qw/cmpthese timethese/;
use C4::Biblio qw(GetMarcSubfieldStructure TransformMarcToKoha );
use C4::XSLT qw(transformMARCXML4XSLT);
use Koha::Biblios;
use Template;

my $biblio = Koha::Biblios->find(5);
my $record = $biblio->metadata->record;
my @items = $record->field(952);
$record->delete_fields(@items);
my $xmlrecord = $biblio->metadata->metadata;
warn $xmlrecord;
my $processor = Template->new();
my $template=q{

[% SET leader = record.leader %]
[% SET leader6 = leader.subtr(6,1) %]
[% SET leader7 = leader.subtr(7,1) %]
[% SET leader19 = leader.subtr(19,1) %]
[% SET tag007 = record.field(007).data %]
[% SET tag007_12 = tag007.substr(12,1) %]
[% set tag008 = record.field(008).data %]
[% SWITCH leader6 %]
    [% CASE 't' %][% SET type008 = 'BK' %][% SET phys_ind = tag008.substr(23,1) %]
        [% IF (tag008.substr(23,1) == ' ' OR tag008 == 'r') %][% physicalDescription _ 'print' %]
    [% CASE ['o','p'] %][% SET type008 = 'MX' %][% SET phys_ind = tag008.substr(23,1) %]
    [% CASE 'm' %]
        [% SET type008 = 'CF' %]
        [% SWITCH tag007_12 %]
            [% CASE 'a' %][% physicalDescription = 'reformatted digital' %]
            [% CASE 'b' %][% physicalDescription = 'digitized microfilm' %]
            [% CASE 'd' %][% physicalDescription = 'digitized other analog' %]
        [% END %]
        [% physicalDescription _ 'electronic' %]
    [% CASE ['e','f'] %][% SET type008 = 'MP' %][% SET phys_ind = tag008.substr(29,1) %]
    [% CASE ['g','k','r' %][% SET type008 = 'VM' %][% SET phys_ind = tag008.substr(29,1) %]
    [% CASE ['i','j'] %][% SET type008 = 'MU' %][% SET phys_ind = tag008.substr(23,1) %]
    [% CASE ['c','d'] %][% SET type008 = 'PR' %][% IF tag008.substr(23,1) == ' ' %][% physicalDescription _ 'print' %]
    [% CASE 'a' %][% SET phys_ind = tag008.substr(23,1) %]
        [% SWITCH leader7 %]
            [% CASE ['a','c','d','m'] %][% SET type008 = 'BK' %]
            [% CASE ['b','i','s'] %][% SET type008 = 'CR' %]
            [% IF (tag008.substr(23,1) == ' ' OR tag008 == 'r') %][% physicalDescription _ 'print' %]
        [% END %]
    [% CASE %][% IF leader19 == 'a' %][% SET type008 = 'BK' %][% END %]
        [% IF (tag008.substr(23,1) == ' ' OR tag008 == 'r') %][% physicalDescription _ 'print' %]
[% END %]
[% SWITCH phys_ind %]
    [% CASE 'f' %][% physicalDescription _ 'braille' %]
    [% CASE 's' %][% physicalDescription _ 'electronic' %]
    [% CASE 'b' %][% physicalDescription _ 'microfiche' %]
    [% CASE 'a' %][% physicalDescription _ 'microfilm' %]
[% END%]

[% tag007 = record.field(007).data %]
[% tag007_1 = tag007.substr(1,1) %]
[% tag007_2 = tag007.substr(2,1) %]
[% SWITCH  tag007_1 %]
    [% CASE 'c' %]
        [% SWITCH tag007_2 %]
            [% CASE 'b' %][% physicalDescription _ 'chip cartridge' %]
            [% CASE 'j' %][% physicalDescription _ 'magnetic disc' %]
            [% CASE 'm' %][% physicalDescription _ 'magneto-optical disc' %]
            [% CASE 'r' %][% physicalDescription _ 'available online' %]
            [% CASE 'a' %][% physicalDescription _ 'tape cartridge' %]
            [% CASE 'f' %][% physicalDescription _ 'tape cassette' %]
            [% CASE 'h' %][% physicalDescription _ 'tape reel' %]
        [% END %]
    [% CASE 'o' %][% IF tag007_2 == 'o' %][% physicalDescription _ 'chip cartridge' %][% END %]
    [% CASE 'a' %]
        [% SWITCH tag007_2 %]
            [% CASE 'd' %][% physicalDescription _ 'atlas' %]
            [% CASE 'g' %][% physicalDescription _ 'diagram' %]
            [% CASE 'j' %][% physicalDescription _ 'map' %]
            [% CASE 'q' %][% physicalDescription _ 'model' %]
            [% CASE 'k' %][% physicalDescription _ 'profile' %]
            [% CASE 'r' %][% physicalDescription _ 'remote sensing image' %]
            [% CASE 's' %][% physicalDescription _ 'section' %]
            [% CASE 'y' %][% physicalDescription _ 'view' %]
        [% END %]
    [% CASE 'h' %]
        [% SWITCH tag007_2 %]
            [% CASE 'a' %][% physicalDescription _ 'aperture card' %]
            [% CASE 'e' %][% physicalDescription _ 'microfiche' %]
            [% CASE 'f' %][% physicalDescription _ 'microfiche cassette' %]
            [% CASE 'b' %][% physicalDescription _ 'microfilm cartridge' %]
            [% CASE 'c' %][% physicalDescription _ 'microfilm cassette' %]
            [% CASE 'd' %][% physicalDescription _ 'microfilm reel' %]
            [% CASE 'g' %][% physicalDescription _ 'microopaque' %]
        [% END %]
    [% CASE 'm' %]
        [% SWITCH tag007_2 %]
            [% CASE 'c' %][% physicalDescription _ 'film cartridge' %]
            [% CASE 'f' %][% physicalDescription _ 'film cassette' %]
            [% CASE 'r' %][% physicalDescription _ 'film reel' %]
        [% END %]
    [% CASE 'k' %]
        [% SWITCH tag007_2 %]
            [% CASE 'c' %][% physicalDescription _ 'collage' %]
            [% CASE 'f' %][% physicalDescription _ 'photomechanical print' %]
            [% CASE 'g' %][% physicalDescription _ 'photonegative' %]
            [% CASE 'h' %][% physicalDescription _ 'photoprint' %]
            [% CASE 'j' %][% physicalDescription _ 'print' %]
            [% CASE 'l' %][% physicalDescription _ 'technical drawing' %]
        [% END %]
    [% CASE 'g' %]
        [% SWITCH tag007_2 %]
            [% CASE 'd' %][% physicalDescription _ 'filmslip' %]
            [% CASE 'c' %][% physicalDescription _ 'filmstrip cartridge' %]
            [% CASE 'o' %][% physicalDescription _ 'filmstrip roll' %]
            [% CASE 'f' %][% physicalDescription _ 'other filmstrip type' %]
            [% CASE 't' %][% physicalDescription _ 'trans[arency' %]
        [% END %]
    [% CASE 'r' %][% IF tag007_2 == 'r' %][% physicalDescription _ 'remote-sensing image' %][% END %]
    [% CASE 's' %]
        [% SWITCH tag007_2 %]
            [% CASE 'e' %][% physicalDescription _ 'cylinder' %]
            [% CASE 'q' %][% physicalDescription _ 'roll' %]
            [% CASE 'g' %][% physicalDescription _ 'sound cartidge' %]
            [% CASE 's' %][% physicalDescription _ 'sound cassette' %]
            [% CASE 't' %][% physicalDescription _ 'sound-tape reel' %]
            [% CASE 'i' %][% physicalDescription _ 'sound-track film' %]
            [% CASE 'w' %][% physicalDescription _ 'wire recording' %]
        [% END %]
    [% CASE 'f' %]
        [% SWITCH tag007_2 %]
            [% CASE 'c' %][% physicalDescription _ 'combination' %]
            [% CASE 'b' %][% physicalDescription _ 'braille' %]
            [% CASE 'a' %][% physicalDescription _ 'moon' %]
            [% CASE 'd' %][% physicalDescription _ 'tactile, with no writing system' %]
        [% END %]
    [% CASE 't' %]
        [% SWITCH tag007_2 %]
            [% CASE 'c' %][% physicalDescription _ 'braille' %]
            [% CASE 'a' %][% physicalDescription _ 'regular print' %]
            [% CASE 'd' %][% physicalDescription _ 'text in looseleaf binder' %]
        [% END %]
    [% CASE 'v' %]
        [% SWITCH tag007_2 %]
            [% CASE 'c' %][% physicalDescription _ 'videocartridge' %]
            [% CASE 'f' %][% physicalDescription _ 'videocassette' %]
            [% CASE 'r' %][% physicalDescription _ 'videoreel' %]
        [% END %]
[% END %]

                <tr>
                    <td>
                        <a class="title" href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% PIECE.subfield(999,'c')%]">[% PIECE.title %]</a>
                        <span class="results_summary publisher">
                            <span class="label">Publicaion details:</span>
                            [% PIECE.field(264).as_string || PIECE.field(260).as_string %]
                    </td>
                    <td>
                </tr>
};

cmpthese(
    -10,
    {
        xslt_parse => sub {
        my $content = 
        C4::XSLT::XSLTParse4Display({
                biblionumber => 5,
                record => $record,
                xsl_syspref  => "XSLTResultsDisplay",
                fix_amps     => 1,
            });
        },
        temaplte_record => sub {
            my $content;
#            $record = transformMARCXML4XSLT(5,$record);
            $processor->process( \$template, { record => $record }, \$content );
        },
    }
);

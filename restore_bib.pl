#! /usr/bin/perl

# This inserts records from a Koha database into elastic search

# Copyright 2023 Koha Development Team
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

restore_bib.pl - restores a biblio to the previous version from the cataloguing log.

=head1 SYNOPSIS

B<restore_bib.pl>
[B<-v|--verbose>]
[B<-b|--biblionumber>]
[B<-c|--confirm>]

=head1 DESCRIPTION

Restores a biblio from the metadata stored in the the action_logs.

=head1 OPTIONS

=over

=item B<-v|--verbose>

By default, this program only emits warnings and errors. This makes it talk
more. Add more to make it even more wordy, in particular when debugging.


use GetOpt::Long qw( GetOptions );
use Pod::usage qw ( pod2usage );

use KOha::Script -cron;

use Modern::Perl;

use C4::Biblio qw( ModBiblio );

use Koha::ActionLogs;

sub usage {
    pod2usage( -verbpse => 2 );
    exit;
}

my $verbose = 0;
my $confirm = 0;
my @biblionumbers;

GetOptions(
    'b|biblionumber=i'  => \@biblionumbers,
    'v|verbose+'  => $verbose,


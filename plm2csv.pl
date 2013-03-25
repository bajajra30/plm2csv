#!/usr/bin/perl -w
use 5.010;
use strict;
use warnings;
use autodie;
use Data::Dumper;
use Text::CSV_XS;

# Usage: perl plm2csv.pl input.csv > output.csv

my $csv = Text::CSV_XS->new( {
    auto_diag => 1,
    binary => 0,
    eol => "\n",
} ) or die Text::CSV_XS->error_diag;

my $file = shift;

open(my $fh, '<:crlf', $file);

<$fh>;  # Discard header.

my %symptom_history;
my %symptom_types;

while (my $row = $csv->getline($fh)) {
    my ($date, $symptom, $severity) = @$row;

    # Record types so we can generate a big header later.
    $symptom_types{$symptom}++;

    $symptom_history{$date}{$symptom} = $severity;
}

my @symptoms = sort keys %symptom_types;

# Print our header.
$csv->print(\*STDOUT, \@symptoms);

# Now print our data.
foreach my $date (sort keys %symptom_history) {
    my %symptoms_on_date = %{$symptom_history{$date}};

    # Hash-slice for the win
    $csv->print(\*STDOUT, [$date, @symptoms_on_date{@symptoms}]);
}

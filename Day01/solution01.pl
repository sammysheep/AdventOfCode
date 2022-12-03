#!/usr/bin/env perl
# S. S. Shepard - 2022

use English qw(-no_match_vars);

local $RS = "\n\n";

my $max_calories = -1;
while ( my $elf_items = <> ) {
    chomp($elf_items);

    my $calories = 0;
    foreach my $cals ( split( "\n", $elf_items ) ) {
        $calories += $cals;
    }

    if ( $calories > $max_calories ) {
        $max_calories = $calories;
    }
}

print STDOUT "Hungriest elf packed $max_calories calories.\n";

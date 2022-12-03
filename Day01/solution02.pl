#!/usr/bin/env perl
# S. S. Shepard - 2022

use English qw(-no_match_vars);

local $RS = "\n\n";

my @elf_calories = ();
while ( my $elf_items = <> ) {
    chomp($elf_items);

    my $calories = 0;
    foreach my $cals ( split( "\n", $elf_items ) ) {
        $calories += $cals;
    }

    push( @elf_calories, $calories );
}

@elf_calories = sort { $b <=> $a } @elf_calories;
if ( scalar @elf_calories > 2 ) {
    my $sum_calories = $elf_calories[0] + $elf_calories[1] + $elf_calories[2];
    print STDOUT "Hungriest 3 elves packed $sum_calories calories.\n";
} else {
    print STDERR "Are you missing data, sir?\n";
}


#!/usr/bin/env raku
# Sam Shepard - 2022
# First-time Raku

my $fh = open "input.txt";
my ($stack, $commands) = $fh.slurp.split("\n\n");

$stack = $stack.split("\n").reverse;
my Int $N =  $stack[0].words.elems;

my @crates = ();
for $stack[1..*] -> $row {
    for $row ~~ m:global/(<alpha>)/ -> $match {
        my ($item, $index) =  ~$match, ($match.pos - 2)  / 4;
        push( @crates[$index], $item);
    }
}

for $commands.trim.split("\n") -> $command {
    my ($quantity, $from, $to) = $command.words[1,3,5];

    for 1..$quantity {
        push(@crates[$to - 1], @crates[$from - 1].pop());
    }
}

for 1..$N -> $i {
    print @crates[$i-1].pop();
}
print "\n";

$fh.close;
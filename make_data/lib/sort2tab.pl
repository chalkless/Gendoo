#!/usr/bin/perl

# sort2tab.pl
# Nakazato T.
# '06-03-03-Fri.    Ver.0

while(defined (my $line = <STDIN>)) {
    $line =~ s/\r//;
    $line =~ s/\n//;

    $line =~ s/^\s+//;

    $line =~ /(\d+)\s(.*)/;
    my $freq = $1;
    my $element = $2;

    print join("\t",$freq, $element)."\n";
}

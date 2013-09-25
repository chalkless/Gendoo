#!/usr/bin/perl

# mk.id2name.pl
# Nakazato T.
# '08-11-04-Tue.    Ver. 0


$debug = 1;

my $file_in = shift @ARGV;     # gene_info

open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    my @ele = split(/\t/, $line_in);

    my $alias_pre = $ele[4]."|".$ele[13];
    my @ele_alias_pre = split(/\|/, $alias_pre);

    @ele_alias = uniqArray(@ele_alias_pre);

    $alias_print = join("|", @ele_alias);

    print join("\t", $ele[1], $ele[2], $ele[8], $alias_print, $ele[9])."\n";
}
close (IN);


sub uniqArray {
    my (@array_pre) = @_;

    @array_uniq = ();
    %hash = ();

    foreach $element (@array_pre) {
        if ($element eq "-") {

        }
        elsif (defined ($hash{$element})) {

        } else {
            $hash{$element} = 1;
            push @array_uniq, $element;
        }
    }

    push @array_uniq, "-" if (@array_uniq == ());

    return @array_uniq;
}

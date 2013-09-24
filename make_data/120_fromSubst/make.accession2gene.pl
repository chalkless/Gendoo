#!/usr/bin/perl

# make.accession2gene.pl
# Nakazato T.
# '08-02-05-Tue.    Ver. 0          Original: make.subst2gene.pl
# '13-09-24-Tue.    Ver. 0.1


$debug = 1;

my ($file_acc2gene, $file_subst2acc) = @ARGV;
open (ACC, $file_acc2gene) or die $!;
while (defined ($line_acc2gene = <ACC>)) {
    $line_acc2gene =~ s/[\r\n]//g;

    @ele_acc2gene = split(/\t/, $line_acc2gene);
    $geneid_id = $ele_acc2gene[1];
    $acc_in = $ele_acc2gene[3];
    $acc_in =~ s/\.\d+$//g;     # omit version

    $acc2gene{$acc_in} = $geneid_in;
}
close (ACC);

open(SUBST, $file_subst2acc) or die $!;
while (defined ($line_subst2acc = <SUBST>)) {
    $line_subst2acc =~ s/[\r\n]//g;

    my ($substid, $subst_name, $acc_subst, $ev) = split(/\t/, $line_subst2acc);

    if ($ev eq "A") {
	$geneid = $acc2gene{$acc_subst};

	if ($geneid eq "") {
	    $geneid = "-";
	}

	print join("\t", $substid, $subst_name, $acc_subst, $geneid)."\n" if $geneid ne "-";
    }
}
close (SUBST);


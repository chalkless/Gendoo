#!/usr/bin/perl

# make.subst2gene.pl
# Nakazato T.
# '08-02-05-Tue.    Ver. 0
# '13-09-24-Tue.    Ver. 0.1


$debug = 1;

my ($file_ref2gene, $file_subst2ref) = @ARGV;
open (REF, $file_ref2gene) or die $!;
while (defined ($line_ref2gene = <REF>)) {
    $line_ref2gene =~ s/[\r\n]//g;

    @ele_ref2gene = split(/\t/, $line_ref2gene);
    $geneid_id = $ele_ref2gene[1];
    $ref_in = $ele_ref2gene[3];
    $ref_in =~ s/\.\d+$//g;     # omit version

    $ref2gene{$ref_in} = $geneid_in;
}
close (REF);

open(SUBST, $file_subst2ref) or die $!;
while (defined ($line_subst2ref = <SUBST>)) {
    $line_subst2ref =~ s/[\r\n]//g;

    my ($substid, $subst_name, $ref_subst, $ev) = split(/\t/, $line_subst2ref);

    if ($ev eq "R") {
	$geneid = $ref2gene{$ref_subst};

	if ($geneid eq "") {
	    $geneid = "-";
	}

	print join("\t", $substid, $subst_name, $ref_subst, $geneid)."\n" if $geneid ne "-";
    }
}
close (SUBST);


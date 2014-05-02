#!/usr/bin/perl

# uniq.subst2gene.pl
# Nakazato T.
# '08-02-05-Tue.    Ver. 0
# '13-10-02-Wed.    Ver. 0.1    refine

$debug = 1;

$file_in = shift @ARGV;
open (NOT, $file_in) or die $!;
while (defined ($line_in = <NOT>)) {
    $line_in =~ s/[\r\n]//g;

    my ($substid, $term, $refseq, $geneid) = split(/\t/, $line_in);
    if ($gene2line{$geneid} ne "") {
        $gene2line{$geneid} = "NG";
	print STDERR join("\t", "Not Uniq Gene", $term, $geneid, $gene2line{$geneid})."\n";
    }
    else {
        $gene2line{$geneid} = $line_in;
    }
}
close (NOT);

foreach $line_uniq_pre (values (%gene2line)) {
    push @data_uniq_pre, $line_uniq_pre;
}

foreach $line_4uniq (@data_uniq_pre) {
    my ($substid, $term, $refseq, $geneid) = split(/\t/, $line_4uniq);

    if ($subst2line{$substid} ne "") {
        $subst2line{$substid} = "NG";
	print STDERR join("\t", "Not Uniq Subst", $term, $substid, $subst2line{$substid})."\n";
    }
    else {
        $subst2line{$substid} = $line_4uniq;
    }
}

foreach $line_uniq (values (%subst2line)) {
    print $line_uniq."\n" if ($line_uniq ne "-");
}

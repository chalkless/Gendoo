#!/usr/bin/perl

# devCategory.gene.pl
# Nakazato T.
# '08-04-04-Fri.    Ver. 0
# '13-09-30-Mon.    Ver. 0.1    refine


$debug = 1;

my ($file_target, $file_table) = @ARGV;

# $file_table = "gene_info.human.tab";

$file_out_prefix = $file_target;
$file_out_prefix =~ s/tab$//;
$file_out_coding = $file_out_prefix."coding.tab";
$file_out_other = $file_out_prefix."other.tab";
if ((-e $file_out_coding) or (-e $file_out_other)) {
    die "Output file exists!"."\n";
}

open (TABLE, $file_table) or die $!;
while (defined ($line_table = <TABLE>)) {
    $line_table =~ s/[\r\n]//g;

    my @ele_gene = split(/\t/, $line_table);
    my $geneid = $ele_gene[1];
    my $gene_type = $ele_gene[9];
    $geneid2type{$geneid} = $gene_type;
}
close (TABLE);

open (CODING, ">$file_out_coding") or die $!;
open (OTHER, ">$file_out_other") or die $!;

open (TARGET, $file_target) or die $!;
while (defined ($line_target = <TARGET>)) {
    $line_target =~ s/\r//;
    $line_target =~ s/\n//;
    my @ele = split(/\t/, $line_target);
    my $geneid = shift @ele;
    my $gene_type = $geneid2type{$geneid};

#    $line_out = join("\t", $geneid, $gene_type, @ele);
    $line_out = join("\t", $geneid, @ele);


    if ($gene_type eq "") {
        print STDERR "NO LINK:"."\t".$line_out."\n";
    }
    elsif (($gene_type eq "miscRNA")
           or ($gene_type eq "rRNA")
           or ($gene_type eq "scRNA")
           or ($gene_type eq "snRNA")
           or ($gene_type eq "snoRNA")
           or ($gene_type eq "tRNA")
           or ($gene_type eq "pseudo")
           or ($gene_type eq "other")
           or ($gene_type eq "unknown")) {
        print OTHER $line_out."\n";
    }
    elsif ($gene_type eq "protein-coding") {
        print CODING $line_out."\n";
    }
    else {
        print STDERR "ERROR:"."\t".$line_out."\n";
    }
}
close (TARGET);

close (PHENO);
close (GENE);


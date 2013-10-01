#!/usr/bin/perl

# devCategory.pl
# Nakazato T.
# '08-04-07-Mon.    Ver. 0
# '13-10-01-Tue.    Ver. 0.1    add F category

$debug = 1;

my ($file_target, $file_table) = @ARGV;

$file_out_prefix = $file_target;
$file_out_prefix =~ s/\.tab$//;

open (TABLE, $file_table) or die $!;
while (defined ($line_table = <TABLE>)) {
    $line_table =~ s/[\r\n]//;

    my ($mid, $mterm, $mtree_pre, $alias) = split(/\t/, $line_table);


    @mtrees = split(/\|/, $mtree_pre);
    $category = "";
    $category_pre = "";

    foreach $each_tree (@mtrees) {
        $each_tree =~ /^(\w\d{2})/;
        $category_tmp = $1;
        $category .= "\|".$category_tmp if $category_pre ne $category_tmp;
        $category_pre = $category_tmp;
    }

    $mterm2cat{$mterm} = $category;

    print join("\t", $mterm, $category)."\n" if $debug == 2;

}
close (TABLE);


open (A, ">$file_out_prefix.A.tab") or die $!;
open (B, ">$file_out_prefix.B.tab") or die $!;
open (C, ">$file_out_prefix.C.tab") or die $!;
open (D, ">$file_out_prefix.D.tab") or die $!;
#open (F, ">$file_out_prefix.F.tab") or die $!;
open (G, ">$file_out_prefix.G.tab") or die $!;
open (S, ">$file_out_prefix.S.tab") or die $!;

open (TARGET, $file_target) or die $!;
while (defined ($line_target = <TARGET>)) {
    $line_target =~ s/[\r\n]//g;

    my ($id, $pmid, $term) = split(/\t/, $line_target);

    if ($term =~ /^S:/) {
        print S $line_target."\n";
    }
    else {
        $term =~ s/^M://;

        $category_out_tmp = $mterm2cat{$term};
        @cats_out = split(/\|/, $category_out_tmp);

        foreach $each_cat (@cats_out) {
	    if (($each_cat =~ /([ABCDG])\d{2}/) or ($each_cat =~ /(F)01/)) {
#		$each_cat_out =~ substr($each_cat, 0, 1);
		$each_cat_out = $1;
		$each_cat_out = "C" if $each_cat_out eq "F";
		print $each_cat_out $line_target."\n";
	    }
        }
    }
}
close (TARGET);

close (S);
close (G);
#close (F);
close (D);
close (C);
close (B);
close (A);

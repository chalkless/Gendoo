#!/usr/bin/perl

# gendooConf.pm
# Nakazato T.
# '08-09-01-Mon.    Ver. 0


package gendooConf;

use Exporter;
@ISA=(EXPORTER);
@EXPORT=qw(f_gene f_mesh f_omim f_mesh2ja f_omim2ja tax2type tax2category);


$debug = 1;

$file_genename = "../data/id2name.=taxonomy=.tab";
$file_omim     = "../data/omim.name.tab";
$file_mesh     = "../data/mesh.term2tree.tab";
$file_subst    = "../data/subst.term2table.tab";
$file_mesh2ja  = "../data/mesh2ja.tab";
$file_omim2ja  = "../data/omim2ja.ev.tab";
$file_mesh2ag  = "../data/mesh2ag.tab";



sub f_gene {
    my ($taxonomy) = @_;

    $file_genename =~ s/=taxonomy=/$taxonomy/;
    print STDERR "[genename at Conf] ".$file_genename."\n" if $debug == 2;

    return ($file_genename);
}

sub f_mesh {
    return ($file_mesh);
}

sub f_omim {
    return ($file_omim);
}

sub f_mesh2ja {
    return ($file_mesh2ja);
}

sub f_omim2ja {
    return($file_omim2ja);
}

sub f_mesh2ag {
    return ($file_mesh2ag);
}



$type{"human"} = ["coding", "other"];
$type{"mouse"} = ["coding", "other"];
$type{"rat"}   = ["coding", "other"];

sub tax2type {
    my ($taxonomy) = @_;

    my $type = $type{$taxonomy};
    $type = ["coding"] if $type eq "";

    return ($type);
}


$category{"human"} = ["C", "D", "G", "A", "B"];
$category{"mouse"} = ["C", "D", "G", "A", "B"];
$category{"rat"}   = ["C", "D", "G", "A", "B"];
$category{"silkworm"} = ["G", "F", "D", "A", "C", "B"];

sub tax2category {
    my ($taxonomy) = @_;

    my $category = $category{$taxonomy};
    $category = ["G", "D", "A", "C", "B"] if $category eq "";

    return ($category);
}


#!/usr/bin/perl

# mesh.term2id.pl
# Nakazato T.
# '13-10-01-Tue.    Ver. 0    original: 660_MeSHName2Id/mesh.name2id.pl


my ($file_target, $file_mesh) = @ARGV;

open (MESH, $file_mesh) or die $!;
while (defined ($line_mesh = <MESH>)) {
    chomp $line_mesh;

    my ($id, $name, $treeid, $alias) = split(/\t/, $line_mesh);
    $meshName2id{$name} = $id;
}
close (MESH);


$file_target = shift @ARGV;
open (IN, $file_target);
while(defined ($line_in = <IN>)) {
    chomp $line_in;

    my ($id, $score, $pvalue, $mesh) = split(/\t/, $line_in);

    $mesh =~ s/^M://;

    $mid = $meshName2id{$mesh};

    print join("\t", $id, $score, $pvalue, $mid)."\n";
}
close (IN);

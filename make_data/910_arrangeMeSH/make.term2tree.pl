#!/usr/bin/perl

# make.term2tree.pl
# Nakazato T.
# '08-04-07-Mon.    Ver. 0
# '08-04-22-Tue.    Ver. 0.01    debug
# '13-09-30-Mon.    Ver. 0.02    refine


$debug = 1;

my $file_mesh = shift @ARGV;
$file_mesh = "/opt/data/MeSH/2013/d2013.bin" if $file_mesh eq "";

open (MESH, $file_mesh) or die $!;
while (defined ($line_mesh = <MESH>)) {
    $line_mesh =~ s/[\r\n]//g;

    if ($line_mesh =~ /\*NEWRECORD/) {
        $term = "";
        $tree_pre = "";
        @trees = ();
    }
    elsif ($line_mesh =~ /^MH =/) {
        $line_mesh =~ /^MH = (.*)$/;
        $mesh = $1;
    }
    elsif ($line_mesh =~ /^MN =/) {
        $line_mesh =~ /^MN = (\w\d{2}(\.\d{3})*)/;
        $tree_pre = $1;
        push @trees, $tree_pre;
    }
    elsif ($line_mesh =~ /^ENTRY =/) {
        $line_mesh =~ /^ENTRY = (.*)$/;
        $entry_pre = $1;
        @entry_ele = split(/\|/, $entry_pre);
        $entry = $entry_ele[0];
        push @entries, $entry;
    }
    elsif ($line_mesh =~ /^UI =/) {
        $line_mesh =~ /^UI = (\w\d{6})/;
        $meshid = $1;
        $mtree_print = join("\|", @trees);

        $entries_print = join("\|", @entries);
        print join("\t", $meshid, $mesh, $mtree_print, $entries_print)."\n";

        @entries = ();
    }
}
close (MESH);

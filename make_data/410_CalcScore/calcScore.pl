#!/usr/bin/perl

# gendoo.mkscore.pl
# Nakazato T.
# '08-04-09-Wed.    Ver. 0
# '13-10-01-Tue.    Ver. 0.1


$debug = 1;

my $file_pair = shift @ARGV;


### Prepare other files
$file_pair =~ /(.{4}).id2mesh\.([^\.]*)\.([^\.]*)\.([ABCDFGS])\..{4}freq\.tab$/;
$type_in = $1;     # gene or omim
$file_db = $2;     # taxonomy
$type_in = $3;     # coding, ....
$category_in = $4;    # A, B, C, D, G, subst

print STDERR join("\t", $file_db, $type_in, $category_in)."\n" if $debug == 2;

my $file_id = $file_pair;
my $file_mesh = $file_pair;
$file_id =~ s/pair/gene/;
$file_mesh =~ s/pair/mesh/;

$file_total = $file_db.".pmid.total.txt";

$file_r_script = $file_pair;
$file_r_rslt   = $file_pair;
$file_ig    = $file_pair;

$file_r_script =~ s/pairfreq/r-scr/;
$file_r_rslt   =~ s/pairfreq/r-rslt/;
$file_ig    =~ s/pairfreq/ig/;


### Read total
open (TOTAL, $file_total) or die $!;
while (defined ($line_total = <TOTAL>)) {
    $line_total =~ s/[\r\n]g//;

    my ($label, $total_tmp) = split(/\t/, $line_total);
    my ($type, $category) = split(/\./, $label);

    $total = $total_tmp if (($type eq $type_in) and ($category eq $category_in));
}
close (TOTAL);


### Read MeSH
open (MESH, $file_mesh) or die $!;
while (defined ($line_mesh = <MESH>)) {
    $line_mesh =~ s/\r//;
    $line_mesh =~ s/\n//;

    my ($freq_mesh, $mesh) = split(/\t/, $line_mesh);
    $mesh2freq{$mesh} = $freq_mesh;
}
close (MESH);


### Read OMIM/gene ID
open (ID, $file_id) or die $!;
while (defined ($line_id = <ID>)) {
    $line_id =~ s/[\r\n]//;

    my ($freq_id, $id) = split(/\t/, $line_id);
    $id2freq{$id} = $freq_id;
}
close (ID);


### calculate score (main)
open (RSCR, ">$file_r_script") or die $!;
open (IG,   ">$file_ig")       or die $!;

open (PAIR, $file_pair) or die $!;
while (defined ($line_pair = <PAIR>)) {
    $line_pair =~ s/\r//;
    $line_pair =~ s/\n//;

    my ($freq_pair, $id_pair, $mesh_pair) = split(/\t/, $line_pair);

    my $freq_id = $id2freq{$id_pair};
    my $freq_mesh = $mesh2freq{$mesh_pair};

    my $a = $freq_pair;
    my $b = $freq_id - $freq_pair;
    my $c = $freq_mesh - $freq_pair;
    my $d = $total - $a - $b - $c;

    print STDERR "[abcd]\t".join("\t", $a, $b, $c, $d)."\n" if $debug == 2;

    $ig = getig($a, $b, $c, $d);
    print STDERR "[InfoGain]\t".$ig."\n" if $debug == 2;

    print IG join("\t", $id_pair, $ig, $mesh_pair)."\n";

    print RSCR "fisher.test(matrix(c($a, $b, $c, $d), nc=2))\$p.value"."\n";
}
close (PAIR);

close (IG);
close (RSCR);


### clear extra memory
undef %mesh2freq;
undef %id2freq;


### calculate p-value
system ("R --vanilla --slave < $file_r_script > $file_r_rslt");

### merge IG and p-value
open (IGRSLT, $file_ig) or die $!;
@ig_rslts = <IGRSLT>;
close (IGRSLT);

open (RRSLT,  $file_r_rslt) or die $!;
@r_rslts = <RRSLT>;
close (RRSLT);

foreach $ig_rslt (@ig_rslts) {
    $ig_rslt =~ s/[\r\n]//g;

    $r_rslt = shift @r_rslts;
    $r_rslt =~ s/[\r\n]//g;
    $r_rslt =~ s/^\[\d+\]\s+//;

    my ($mimid_rslt, $ig_rslt, $term_rslt) = split(/\t/, $ig_rslt);

    print join("\t", $mimid_rslt, $ig_rslt, $r_rslt, $term_rslt)."\n";
}

### calculate information gain
sub getig {
    my ($x, $y, $z, $w) = @_;

    foreach $p ($x, $y, $z, $w) {
        $p = 1e-20 if ($p == 0);
    }


    $t = $x + $y + $z + $w;


    $sx = $x * log($x * $t / ($x + $y) / ($x + $z));
    $sy = $y * log($y * $t / ($y + $w) / ($y + $x));
    $sz = $z * log($z * $t / ($z + $x) / ($z + $w));
    $sw = $w * log($w * $t / ($w + $z) / ($w + $y));

    my ($ig_pre) = ($sx + $sy + $sz + $sw) / $t;

    my ($ig_pre2) = $ig_pre / log(2);

    $ig = sprintf("%.5e", $ig_pre2);

    return $ig;
}


sub getpval {
    my ($x,  $y, $z, $w) = @_;

    $script = "/tmp/rwrap$$.R";
    open(SCRIPT, ">$script");
    print SCRIPT <<EOF;
    fisher.test(matrix(c($x, $y, $z, $w), nc=2))\$p.value
    q()
EOF
close(SCRIPT);
    $rslts = `R --vanilla --slave < $script`;

    $rslts =~ s/\r//;
    $rslts =~ s/\n//;

    $rslts =~ s/^\[\d+\]\s+//;

    return $rslts;
    unlink $script;

}

#!/usr/bin/perl

# makeSubst2PMID.pl
# Nakazato T.
# '08-02-20-Wed.    Ver. 0
# '13-10-02-Wed.    Ver. 0.1    refine

use Bio::Biblio;


$debug = 1;

my ($file_in) = shift @ARGV;
open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    next if ($line_in eq "NG");

    my ($substid, $substterm, $refseqid, $geneid) = split(/\t/, $line_in);

    $pmids_ref = getPMID($substterm."[Substance Name]");
    @pmids = @$pmids_ref;

    foreach $each_pmid (@pmids) {
        print join("\t", $geneid, $each_pmid, "S")."\n";
    }
}
close (IN);


sub getPMID {
    my ($term) = @_;

    $biblio = Bio::Biblio->new(-access => 'eutils');
    my ($articles_ref) = $biblio->find($term);
    my ($pmids_ref) = $articles_ref->get_all_ids();
    my ($pmids_ref) = Bio::Biblio->new(-access => "eutils")->find($term)->get_all_ids();

    print STDERR join("\n", @$pmids_ref)."\n" if ($debug == 2);

    return ($pmids_ref);
}

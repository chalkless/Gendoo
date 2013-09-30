#!/usr/bin/perl -w

# pair2mesh.pl
# Nakazato T.
# '08-03-07-Fri.    Ver. 0


use Bio::Biblio;
use Bio::Biblio::IO;
use Data::Dumper;


$debug = 1;


my ($file_in) = shift @ARGV;

open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/\r//g;
    $line_in =~ s/\n//g;

    my ($mimid, $pmid_list) = split(/\t/, $line_in);
    @pmid_list = split(/\|/, $pmid_list);

    while (@pmid_list) {
	my @pmid_sub = splice(@pmid_list, 0, 100);
	my $pmid_str = join(",", @pmid_sub);

	$rslt_xml = getxml($pmid_str);

        $rslt_xml = getxml($pmid_str) if $rslt_xml eq "";    # for backup

	my $biblio_obj = Bio::Biblio::IO->new(-data   => $rslt_xml,
					      -format => 'medlinexml');

	while ($each_ref = $biblio_obj->next_bibref()) {

	    my ($pmid) = $each_ref->pmid();

	    $mesh_array_ref = $each_ref->mesh_headings();
	    foreach $each_mesh_obj (@$mesh_array_ref) {
		print Dumper($each_mesh_obj)."\n" if ($debug == 2);
		$meshterm = $each_mesh_obj->{"descriptorName"};
		print join("\t", $mimid, $pmid, "M:".$meshterm)."\n";
	    }

	    $subst_array_ref = $each_ref->chemicals();
	    foreach $each_subst_obj (@$subst_array_ref) {
		$substterm = $each_subst_obj->{"nameOfSubstance"};
		print join("\t", $mimid, $pmid, "S:".$substterm)."\n";
	    }
	}
    }
}
close (IN);

exit;


sub getxml {
    my ($pmid) = @_;

#    sleep 2;
    my $biblio = Bio::Biblio->new(-access => 'eutils');
    my $xml = $biblio->get_by_id($pmid);

    return $xml;

    1;
}


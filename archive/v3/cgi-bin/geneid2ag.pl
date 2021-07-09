#!/usr/bin/perl

# geneid2ag.pm
# Nakazato T.
# '09-10-01-Thu.    Ver. 0


#require "./gendooCommon.pm";
require "./gendooConf.pm";

my $debug = 1;

my ($geneid, $taxonomy) = @ARGV;

push @geneids_tmp, $geneid;

$geneids_ref = \@geneids_tmp;

my (@geneids) = initialize($geneids_ref, $taxonomy);

my ($type_ref) = gendooConf::tax2type($taxonomy);
@type = @$type_ref;

foreach $each_type (@type) {
    my $file_target = join("\.", "score", "gene", $taxonomy, $each_type, "A", "tab");

    my $id_search = join("\|", @geneids);

    open (TARGET, "../data/".$file_target) or die $!." $file_target";
    @lines_hit = grep { $_ =~ /^($id_search)\t/ } <TARGET>;
    close (TARGET);

    foreach $each_hit (@lines_hit) {
	$each_hit =~ s/[\r\n]//g;

	my ($geneid, $score, $pvalue, $meshid) = split(/\t/, $each_hit);

	$meshid2score{$meshid} += $pvalue;
    }
}

foreach $each_meshid ( sort { $meshid2score{$a} <=> $meshid2score{$b} } keys %meshid2score ) {
    $ag_tmp = $meshid2ag{$each_meshid};
    $ag_pvalue = $meshid2score{$each_meshid};

    if ($ag_pvalue >= 0.05) {
	$ag_color = "128,128,128";
    }
    elsif ($ag_pvalue >= 0.005) {
	$ag_color = "255,255,128";
    }
    elsif ($ag_pvalue < 0.005) {
	$ag_color = "255, 0, 255";
    }
    else {
	$ag_color = "-1";
    }

    push @ags_out, $ag_tmp.",".$ag_color if $ag_tmp ne "";
}

push @ags_out, "全身,-1,0.1";

print join("\;", @ags_out)."\n";


sub initialize {
    my ($geneids_ref, $taxonomy) = @_;
    my @geneids = @$geneids_ref;
#    my @geneids = gendooCommon::uniqArray(@geneids_pre);

#    $file_genename = gendooConf::f_gene($taxonomy);
#    $file_mesh = gendooConf::f_mesh();
#    $file_mesh2ja = gendooConf::f_mesh2ja();
    $file_mesh2ag = gendooConf::f_mesh2ag();

    open (MESH2AG, $file_mesh2ag) or die $!;
    while (defined ($line_mesh2ag = <MESH2AG>)) {
	$line_mesh2ag =~ s/[\r\n]//g;

	my ($meshid, $meshterm, $agterm, $fmaid) = split(/\t/, $line_mesh2ag);

	$meshid2ag{$meshid} = $agterm;
    }
    close (MESH2AG);

    return (@geneids);
}



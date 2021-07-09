#!/usr/bin/perl

# meshid2score.pm
# Nakazato T.
# '08-07-29-Tue.    Ver. 1
# '08-08-11-Mon.    Ver. 1.0001


package meshid2score;

use CGI;
use Data::Dumper;
use Exporter;
@ISA=(EXPORTER);
@EXPORT=qw(call);

require "./gendooCommon.pm";
require "./gendooConf.pm";

my $debug = 1;



sub initialize {
    my ($taxonomy) = @_;

    $file_genename = gendooConf::f_gene($taxonomy);
    $file_mesh = gendooConf::f_mesh();
    $file_omim = gendooConf::f_omim();

    %category = ( "C" => ["Disease", "disease"],
		  "D" => ["Chemicals", "chemical"],
		  "G" => ["Biological Phenomena", "biolphenom"],
		  "A" => ["Anatomy", "anatomy"],
		  "B" => ["Organisms", "organism"] );

    open (GENENAME, $file_genename) or die $!;
    while (defined ($line_genename = <GENENAME>)) {
	my @ele_genename = split(/\t/, $line_genename);
	my $geneid = $ele_genename[0];
	my $symbol = $ele_genename[1];
	$id2genename{$geneid} = $symbol;
    }
    close (GENENAME);

    open (MESH, $file_mesh) or die $!;
    while (defined ($line_mesh = <MESH>)) {
	$line_mesh =~ s/\r//g;
	$line_mesh =~ s/\n//g;

	my ($meshid, $mesh_term, $mesh_tree) = split(/\t/, $line_mesh);
	$meshid2term{$meshid} = $mesh_term;
    }
    close (MESH);

    open (OMIM, $file_omim) or die $!;
    while (defined ($line_omim = <OMIM>)) {
	$line_omim =~ s/\r//g;
	$line_omim =~ s/\n//g;

	my ($omimid, $omim_symbol, $omim_desc, $omim_alias, $status) = split(/\t/, $line_omim);
	if ($omim_symbol eq "-") {
	    $omimid2name{$omimid} = lc($omim_desc);
	}
	else {
	    $omimid2name{$omimid} = $omim_symbol;
	}

    }
    close (OMIM);

}


sub call {
    my ($meshids_ref, $taxonomy) = @_;

    initialize($taxonomy);

    printHeader();

    my @meshids_pre = @$meshids_ref;
    my @meshids = gendooCommon::uniqArray(@meshids_pre);

    printQueries(@meshids);

    print "<br>"."\n";

    print $page->hr();

    print "<form method=\"GET\" action=\"gendoo.cgi\">"."\n";
    print "<input name=\"taxonomy\" type=\"hidden\" value=\"$taxonomy\">";


    $type_ref = gendooConf::tax2type($taxonomy);
    @type = @$type_ref;

#    if ($taxonomy eq "human") {
#	@type = ("coding", "other");
#    }
#    else {
#	@type = ("coding");
#    }

    ### Gene
    foreach $each_cat ("C", "D", "G", "A", "B") {
	foreach $each_type (@type) {
	    my $file_target = join("\.", "score", "gene", $taxonomy, $each_type, $each_cat, "tab");
	    my $id_search = join("\|", @meshids);

	    open (TARGET, "../data/".$file_target) or die $!;
	    my @lines_hit = grep { $_ =~ /\t($id_search)$/ } <TARGET>;
	    close (TARGET);

	    foreach $each_hit (@lines_hit) {
		$each_hit =~ s/\r//g;
		$each_hit =~ s/\n//g;

		my ($geneid, $score, $pvalue, $meshid) = split(/\t/, $each_hit);

		print join("\t", $geneid, $score, $pvalue, $meshid)."<br>"."\n" if $debug == 2;

		$sumscore{$geneid} += $score;
		$score{$meshid}{$geneid} = [$score, $pvalue];
	    }
	}
    }

    print $page->h2($page->a({name => "gene"}, "Gene"));

    print <<RSLTHEAD;

<table border>
 <tr>
  <th><br></th>
  <th>Gene</th>
  <th>Link</th>
  <th>Information<br>Gain</th>
RSLTHEAD

$mesh_print = 1;

foreach $each_meshid (@meshids) {
#    $mesh_term = $meshid2term{$each_meshid};
    print "  <th style=\"width: 18px;\">".(sprintf "%02d", $mesh_print)."</th>"."\n";
    $mesh_print++;
}
    print " </tr>"."\n";



    foreach $each_geneid (sort {$sumscore{$b} <=> $sumscore{$a} } keys %sumscore) {
	my $genename = $id2genename{$each_geneid};

	$genename = $each_geneid if $genename eq "";

	my $link_gendoo = "gendoo.cgi?geneid=".$each_geneid."&taxonomy=".$taxonomy;
	my $link_gene = "http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=DetailsSearch&Term=$each_geneid";

	print <<RSLTBODY;
 <tr>
  <td>
   <input name="geneid" type="checkbox" value="$each_geneid">
  </td><td>
   <a href="$link_gendoo">$genename</a>
  </td><td>
   <a href="$link_gene">[NCBI]</a>
  </td><td>
  $sumscore{$each_geneid}
  </td>
RSLTBODY

        foreach $each_meshid (@meshids) {
	    if (defined ($score{$each_meshid}{$each_geneid})) {
		my $each_score_ref = $score{$each_meshid}{$each_geneid};
		($each_score, $each_pvalue) = @$each_score_ref;
	    }
	    else {
		($each_score, $each_pvalue) = (0, 1);
	    }
	

	$each_bgcolor = gendooCommon::score2style($each_pvalue, "list");

	print "  <td class=\"$each_bgcolor\" title=\"IG=$each_score, p-value=$each_pvalue\">";
	print "<br>";
#	print $each_score;
	print "</td>"."\n";
        }
    }
    print "</table>"."\n";

    print "<br>"."\n";

    print "<input name=\"submit\" type=\"submit\" value=\"Search\">"."\n";
    print "<input name=\"reset\"  type=\"reset\"  value=\"Reset\">"."\n";

    print "<br>"."\n";
    print "<br>"."\n";
    print "<hr>"."\n";
    print "\n";



    undef %sumscore;



    ### OMIM
    foreach $each_cat ("C", "D", "G", "A", "B") {
	foreach $each_type ("gene", "locus", "phenotype") {
	    my $file_target = join("\.", "score", "omim", $each_type, $each_cat, "tab");
	    my $id_search = join("\|", @meshids);

	    open (TARGET, "data/".$file_target) or die $!;
	    my @lines_hit = grep { $_ =~ /\t($id_search)$/ } <TARGET>;
	    close (TARGET);

	    foreach $each_hit (@lines_hit) {
		$each_hit =~ s/\r//g;
		$each_hit =~ s/\n//g;

		my ($omimid, $score, $pvalue, $meshid) = split(/\t/, $each_hit);

		$sumscore{$omimid} += $score;
		$score{$meshid}{$omimid} = [$score, $pvalue];
	    }
	}
    }

    print $page->h2($page->a({name => "omim"}, "OMIM"));

    print <<RSLTHEAD;

<table border>
 <tr>
  <th><br></th>
  <th>OMIM</th>
  <th>Link</th>
  <th>Information<br>gain</th>
RSLTHEAD

    $mesh_print = 1;

    foreach $each_meshid (@meshids) {
	print "  <th style=\"width: 18px;\">".(sprintf "%02d", $mesh_print)."</th>"."\n";
	$mesh_print++;
    }

    print " </tr>"."\n";


    foreach $each_omimid (sort {$sumscore{$b} <=> $sumscore{$a} } keys %sumscore) {
	my $omimname = $omimid2name{$each_omimid};

	my $link_gendoo = "gendoo.cgi?omimid=".$each_omimid."&taxonomy=".$taxonomy;
	my $link_omim   = "http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=".$each_omimid;

	print <<RSLTBODY;
 <tr>
  <td>
   <input name="omimid" type="checkbox" value="$each_omimid">
  </td><td>
   <a href="$link_gendoo">$omimname</a>
  </td><td>
   <a href="$link_omim">[NCBI]</a>
  </td><td>
  $sumscore{$each_omimid}
  </td>
RSLTBODY

        foreach $each_meshid (@meshids) {
	    if (defined ($score{$each_meshid}{$each_omimid})) {
		my $each_score_ref = $score{$each_meshid}{$each_omimid};
		($each_score, $each_pvalue) = @$each_score_ref;
	    }
	    else {
		($each_score, $each_pvalue) = (0, 1);
	    }

	    $each_bgcolor = gendooCommon::score2style($each_pvalue, "list");

	    print "  <td class=\"$each_bgcolor\" title=\"IG=$each_score, p-value=$each_pvalue\">";
	    print "<br>";
#	    print $each_score;
	    print "</td>"."\n";
        }
    }

    print "</table>"."\n";

    print "<br>"."\n";

    print "<input name=\"submit\" type=\"submit\" value=\"Search\">"."\n";
    print "<input name=\"reset\"  type=\"reset\"  value=\"Reset\">"."\n";


    print "</form>"."\n";


    print "<br>"."\n";
    print "<br>"."\n";
    print "\n";


    print "<hr>";


    printFooter();
}

sub printHeader {
    $page = CGI->new();

    print $page->header();
    print $page->start_html(-title => "Gendoo",
			    -style => {-src => "../gendoo.css" } );

    print $page->h1($page->a({href => "../index.html"},
			     $page->img({ src => "../images/gendoo.logo-s.png",
					           border => 0,
                                 width  => 222,
                                 height => 51,
					  alt    => "Gendoo"})));

#    print $page->h1($page->a({href=>"../index.html"}, "Gendoo"));

    print $page->h2("MeSH keywords -> Related genes, diseases (OMIM)");

    print "<br>"."\n";
}

sub printFooter {
    print "<p style=\"text-align: right;\"><a href=\"http://dbcls.rois.ac.jp/\">Database Center for Life Science</a>";

    print $page->end_html;
}


sub printQueries {
    my (@meshids) = @_;

    print $page->h3("Query MeSH keywords list");
    print "<table border>"."\n";

    my $meshid_grep = "(".join("|", @meshids).")";

    open (MESH, $file_mesh) or die $!;
    my @lines_hit = grep { $_ =~ /^$meshid_grep\t/ } <MESH>;
    close (MESH);


    foreach $line_name (@lines_hit) {
	my ($meshid, $meshterm, $tree) = split(/\t/, $line_name);
	$meshid2term{$meshid} = $meshterm;
    }

    my $mesh_print = 1;

    foreach $each_meshid (@meshids) {
	my  $mesh_num = sprintf "%02d", $mesh_print;

	$meshterm = $meshid2term{$each_meshid};
	my $link_mesh="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=mesh&Cmd=DetailsSearch&Term=%22".$meshterm."%22%5BMeSH+Terms%5D";

	print <<MESHNAME;
 <tr style="text-align: left;">
  <th>$mesh_num</th>
  <th>$meshterm</th>
  <th><a href="$link_mesh">[NCBI]</a></th>
 </tr>
MESHNAME


$mesh_print++;
    }

    print "</table>"."\n";
}

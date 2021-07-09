#!/usr/bin/perl

# omimid2score.
# Nakazato T.
# '08-08-11-Mon.    Ver. 1
# '08-12-31-Wed.    Ver. 1.0001


package omimid2score;

use CGI;
use Data::Dumper;
use Exporter;
@ISA=(EXPORTER);
@EXPORT=qw(call);

require "./gendooCommon.pm";
require "./gendooConf.pm";

my $debug = 1;


sub call {
    my ($omimids_ref) = @_;

    $file_omimname = gendooConf::f_omim();
    $file_mesh     = gendooConf::f_mesh();
    $file_mesh2ja  = gendooConf::f_mesh2ja();
    $file_omim2ja  = gendooConf::f_omim2ja(); 

    %category = ( "C" => ["Disease", "disease"],
                  "D" => ["Chemicals", "chemical"],
                  "G" => ["Biological Phenomena", "biolphenom"],
                  "A" => ["Anatomy", "anatomy"],
                  "B" => ["Organisms", "organism"] );

    printHeader();

    my @omimids_pre = @$omimids_ref;
    my @omimids_pre2 = gendooCommon::uniqArray(@omimids_pre);
    my @omimids = cleanQueries(@omimids_pre2);

    createJaDic();

    printQueries(@omimids);

    print "<br><br>"."\n";

    catLink();

    print $page->hr();

    print "<form method=\"GET\" action=\"gendoo.cgi\">"."\n";
    print "<input name=\"taxonomy\" type=\"hidden\" value=\"human\">"."\n";

    ($id2omimname_ref, $meshid2term_ref) = createTableOMIMMeSH();

    %id2omimname = %$id2omimname_ref;
    %meshid2term = %$meshid2term_ref;


### Result

# print Result

    foreach $each_cat ("C", "D", "G", "A", "B") {
	foreach $each_type ("gene", "locus", "phenotype") {
	    my $file_target = join("\.", "score", "omim", $each_type, $each_cat, "tab");
	    my $id_search = join("\|", @omimids);

	    open (TARGET, "data/".$file_target) or die $!;
	    @lines_hit = grep { $_ =~ /^($id_search)\t/ } <TARGET>;
	    close (TARGET);

	    foreach $each_hit (@lines_hit) {
		$each_hit =~ s/\r//g;
		$each_hit =~ s/\n//g;

		my ($omimid, $score, $pvalue, $meshid) = split(/\t/, $each_hit);

		print join("\t", $omimid, $score, $pvalue, $meshid)."<br>"."\n" if $debug == 2;

		if ($pvalue == 0) {
		    $log = -1000;
		}
		else {
		    $log = log($pvalue)/log(10);
		}

		$sumscore{$meshid} += $log;
		$score{$meshid}{$omimid} = [$score, $pvalue];
	    }
	}

	my $title_ref = $category{$each_cat};
	my ($title, $link_title) = @$title_ref;

	print $page->h2($page->a({name => $link_title}, $title));

	my $link_tree_id;
	$link_tree_id .= "omimid=".$_."&" foreach @omimids;
	$link_tree_id =~ s/\&$//;
	my $link_tree = "gendoo.cgi?".join("&", $link_tree_id, "taxonomy=".$taxonomy, "category=".$each_cat, "view=tree");
	print $page->p("&#8594; ".$page->a({href=>$link_tree}, "Tree View"));


	print <<RSLTHEAD;
<table border>
 <tr>
  <th><br></th>
  <th>MeSH term</th>
  <th>Japanese</th>
  <th>Link</th>
<!--  <th>Information Gain</th> -->
RSLTHEAD

$omim_print = 1;

	foreach $each_omimid (@omimids) {
	    print "  <th style=\"width: 18px;\">".(sprintf "%02d", $omim_print)."</th>"."\n";
	    $omim_print++;
	}
	print " </tr>"."\n";


	foreach $each_mesh (sort {$sumscore{$a} <=> $sumscore{$b} } keys %sumscore) {
	    my $meshterm = $meshid2term{$each_mesh};
	    my $meshja = $meshid2ja{$each_mesh};

	    my $link_gendoo = "gendoo.cgi?meshid=".$each_mesh."&taxonomy=human";
	    my $link_mesh = "http://www.ncbi.nlm.nih.gov/sites/entrez?Db=mesh&Cmd=DetailsSearch&Term=%22".$meshterm."%22%5BMeSH+Terms%5D";
	    my $link_lsdb = "http://biosciencedbc.jp/dbsearch/?phrase=$meshterm | $meshja";

	    print <<RSLTBODY;
 <tr>
  <td>
   <input name="meshid" type="checkbox" value="$each_mesh">
  </td><td>
   <a href="$link_gendoo">$meshterm</a>
  </td><td>
   $meshja
  </td><td>
   <a href="$link_mesh" title="MeSH (NCBI)"><img src="../images/gd.mesh.png" width=32 height=17 border=0 alt="MeSH"></a>
   <a href="$link_lsdb" title="lifesciencedb.jp"><img src="../images/gd.lsdb.png" width=32 height=17 border=0 alt="lifesciencedb.jp"></a>
  </td><!-- <td>
   $sumscore{$each_mesh}
  </td> -->
RSLTBODY

            foreach $each_omim (@omimids) {
		if (defined ($score{$each_mesh}{$each_omim})) {
		    my $each_score_ref = $score{$each_mesh}{$each_omim};
		    ($each_score, $each_pvalue) = @$each_score_ref;
		}
		else {
		    ($each_score, $each_pvalue) = (0, 1);
		}

		$each_bgcolor = gendooCommon::score2style($each_pvalue, "list");

		print "  <td class=\"$each_bgcolor\" title=\"IG=$each_score, p-value=$each_pvalue\"><br></td>"."\n";
            }
	    print " </tr>"."\n";
	}

	print <<RSLTFOOTER;
</table>

<br>

<input name="submit" type="submit" value="Search">
<input name="reset" type="reset" value="Reset">

<br>

<hr>
RSLTFOOTER

	undef %sumscore;
    }

    print "</form>"."\n";

    printFooter();
}



sub printHeader {
    $page = CGI->new();

#    print $page->header();
    print "content-type: text/html; charset=utf-8\n\n";
    print $page->start_html(-title => "Gendoo - Relevant features",
			    -style => [{-src => "../gendoo.tmp.css"},
			    {-src => "../gendoo.css"}],
);

    print $page->h1($page->a({href => "../index.html"},
		    $page->img({ src => "../images/gendoo.logo-s.png",
			         border => 0,
			         width  => 222,
			         height => 51,
			         alt    => "Gendoo"})));
#    print $page->h1($page->a({href => "../index.html"}, "Gendoo"));

    print $page->h2("OMIM &#8594; Related disease, drugs, ...");
    print "<br>"."\n";

}

sub printFooter {
    print "<p style=\"text-align: right;\"><a href=\"http://dbcls.rois.ac.jp/\">Database Center for Life Science</a>";

    print $page->end_html();
}


sub cleanQueries {
    my (@omimids_pre) = @_;

    my @omimids;

    foreach $each_query (@omimids_pre) {
	$each_query =~ s/^[\#\%\*\+\^]\s*//;
	push @omimids, $each_query;
    }
    return (@omimids);
}


sub catLink {
    foreach $each_category ("C", "D", "G", "A", "B") {
        my $cat_name_ref = $category{$each_category};
        my ($cat_title, $cat_link) = @$cat_name_ref;
        push @links, $page->a({href => "#".$cat_link}, $cat_title);
    }
    print join(" : ", @links)."\n";
}


sub printQueries {
    my (@omimids) = @_;

    print $page->h3("Query OMIM entry list");
    print "<table border>"."\n";

    my $omimid_grep = "(".join("|", @omimids).")";

    open (OMIM, $file_omimname) or die $!;
    my @lines_hit = grep { $_ =~ /^$omimid_grep\t/ } <OMIM>;
    close (OMIM);

    foreach $line_name (@lines_hit) {
	my ($id, $symbol, $desc, $alias, $type) = split(/\t/, $line_name);
	$omimid2names{$id} = [$symbol, $desc, $type];
    }

    my $omim_print = 1;

    foreach $each_omimid (@omimids) {
	my $omim_num = sprintf "%02d", $omim_print;

	my $omim_names_ref = $omimid2names{$each_omimid};
	my ($symbol, $desc, $type) = @$omim_names_ref;
	my ($omim_ja) = $omimid2ja{$each_omimid};

	print <<OMIMNAME;
 <tr style="text-align: left; vertical-align: bottom;">
  <td>$omim_num</td>
  <td>$each_omimid</td>
  <th>$symbol</th>
  <td>$desc</td>
  <td>$omim_ja</td>
  <td>
    <a href="http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=$each_omimid"><img src="../images/gd.omim.png" width=32 height=17 border=0 alt="OMIM"></a>
   </td>
 </tr>
OMIMNAME


$omim_print++;
    }
    print "</table>"."\n";
}


sub createTableOMIMMeSH {
    open (OMIMNAME, $file_omimname) or die $!;
    while (defined ($line_omimname = <OMIMNAME>)) {
	my @ele_omimname = split(/\t/, $line_omimname);
	my $omimid = $ele_omimname[0];
	my $symbol = $ele_omimname[1];
	$id2omimname{$omimid} = $symbol;
    }
    close (OMIMNAME);

    open (MESH, $file_mesh) or die $!;
    while (defined ($line_mesh = <MESH>)) {
	$line_mesh =~ s/\r//g;
	$line_mesh =~ s/\n//g;

	my ($meshid, $mesh_term, $mesh_tree) = split(/\t/, $line_mesh);
	$meshid2term{$meshid} = $mesh_term;
    }
    close (MESH);

    return (\%id2omimname, \%meshid2term);
}


sub createJaDic {
    open (MESH2JA, $file_mesh2ja) or die $!;
    while (defined ($line_mesh2ja = <MESH2JA>)) {
	$line_mesh2ja =~ s/[\r\n]//g;

	my ($meshid, $ja) = split(/\t/, $line_mesh2ja);
	$meshid2ja{$meshid} = $ja;
    }
    close (MESH2JA);

    open (OMIM2JA, $file_omim2ja) or die $!;
    while (defined ($line_omim2ja = <OMIM2JA>)) {
	$line_omim2ja =~ s/[\r\n]//g;

	my ($omimid, $ja, $alias, $ev) = split(/\t/, $line_omim2ja);
	my ($ja_out) = $ja;
	if (($alias ne "-") and ($alias ne "")) {
	    $ja_out = join("\|", $ja, $alias);
	}
	$omimid2ja{$omimid} = $ja_out;
    }
    close (OMIM2JA);
}


1;

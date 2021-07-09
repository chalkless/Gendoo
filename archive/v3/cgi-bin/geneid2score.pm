#!/usr/bin/perl -w

# geneid2score.pm
# Nakazato T.
# '08-07-18-Fri.    Ver. 1
# '09-06-19-Fri.    Ver. 2


package geneid2score;

use utf8;
#binmode STDOUT, ":utf8";
use Encode;
use Template;
#use CGI;
use Data::Dumper;
use Exporter;
@ISA=(Exporter);
@EXPORT=qw(call);

require "./gendooCommon.pm";
require "./gendooConf.pm";


my $debug = 1;


sub call {
    my ($geneidsorg_ref, $taxonomy) = @_;

    my ($geneids_ref, $cat_ref, $type_ref) = initialize($geneidsorg_ref, $taxonomy);


    print "content-type: text/html; charset=utf-8\n\n";

    $template = Template->new(
			      UNICODE  => 1,
			      ENCODING => 'utf-8');

    my ($query) = printQueries(@$geneids_ref);
    my ($link)  = catLink(@$cat_ref);

    printScreen($query, $link, $taxonomy);

    createMeshDic();

#    ($id2genename_ref, $meshid2term_ref) = createTableGeneMeSH();

#    %id2genename = %$id2genename_ref;
#    %meshid2term = %$meshid2term_ref;

    grepTable($cat_ref, $type_ref, $taxonomy, $geneids_ref);

    print "</form>\n";
    print "</body>\n";
    print "</html>\n";
}


### Result


sub grepTable {
    my ($cat_ref, $type_ref, $taxonomy, $geneids_ref) = @_;

    foreach $each_cat (@$cat_ref) {

	my $title_ref = $category{$each_cat};
	my ($title, $link_title) = @$title_ref;

###	push @rslt_title, ({category => $title, genename => \@genename, rbody => \%rbody});

	print "<h2><a name=\"$link_title\">$title</a></h2>\n";

#	print $page->h2($page->a({name=>$link_title}, $title));

	my $link_tree_id;
	$link_tree_id .= "geneid=".$_."&" foreach @$geneids_ref;
	$link_tree_id =~ s/\&$//;
	my $link_tree = "gendoo.cgi?".join("&", $link_tree_id, "taxonomy=".$taxonomy, "category=".$each_cat, "view=tree");
	print "&#8594;<a href=\"$link_tree\">Tree View</a>"."\n";
        print "<br><br>\n";
#	print $page->p("&#8594; ".$page->a({href=>$link_tree}, "Tree View"));



	# Table Header
	print "<table border>"."\n";
	print " <tr>"."\n";
	print "  <th><br></th>"."\n";
	print "  <th>MeSH term</th>"."\n";
	print "  <th>Japanese</th>"."\n";
	print "  <th>Link</th>"."\n";
#	print "  <th>Information<br>Gain</th>"."\n";

	foreach $each_geneid (@$geneids_ref) {
	    $genename = $id2genename{$each_geneid};
	    @genename_ele = split(//, $genename);
	    $genename_print = join("<br>", @genename_ele);
	    print "  <th style=\"width: 18px;\">$genename_print</th>"."\n";
	}
	print " </tr>"."\n";

# retrieve result
	($sumscore_ref, $score_ref) = grepRsltPair($each_cat, $type_ref, $taxonomy, $geneids_ref);

	%sumscore = %$sumscore_ref;
	%score = %$score_ref;

	foreach $each_mesh (sort {$sumscore{$a} <=> $sumscore{$b} } keys %sumscore) {
	    my $meshterm = $meshid2term{$each_mesh};
	    my $mesh_ja = $meshid2ja{$each_mesh};

	    my $link_gendoo = "gendoo.cgi?meshid=".$each_mesh."&taxonomy=".$taxonomy;
	    my $link_mesh = "http://www.ncbi.nlm.nih.gov/sites/entrez?Db=mesh&Cmd=DetailsSearch&Term=%22".$meshterm."%22%5BMeSH+Terms%5D";

	    my $mesh_lsdb = $meshterm." \| ".$mesh_ja;

#	    my $link_lsdb = "http://lifesciencedb.jp/dbsearch/\?phrase=$mesh_lsdb";
	    my $link_lsdb = "http://biosciencedbc.jp/dbsearch/\?phrase=$mesh_lsdb";

	    print " <tr>"."\n";
	    print "  <td>"."\n";
	    print "  <input name=\"meshid\" type=\"checkbox\" value=\"$each_mesh\">"."\n";
	    print "  </td><td>"."\n";
	    print "   <a href=\"$link_gendoo\">$meshterm</a>"."\n";
	    print "  </td><td>"."\n";
	    print "   $mesh_ja"."\n";
	    print "  </td><td>"."\n";
	    print "   <a href=\"$link_mesh\" title=\"MeSH (NCBI)\"><img src=\"../images/gd.mesh.png\" width=32 height=17 border=0 alt=\"MeSH\"></a>";
	    print "   <a href=\"$link_lsdb\" title=\"lifesciencedb.jp\"><img src=\"../images/gd.lsdb.png\" width=32 height=17 border=0 alt=\"lifesciencedb.jp\"></a>";
	    print "\n";
#	print "  </td><td>"."\n";
#	print "   $sumscore{$each_mesh}"."\n";
	    print "  </td>"."\n";

	    print join("\t", $each_mesh, $meshterm, $sumscore{$each_mesh}) if $debug == 2;

	    foreach $each_gene (@$geneids_ref) {
		if (defined ($score{$each_mesh}{$each_gene})) {
		    my $each_score_ref = $score{$each_mesh}{$each_gene};
		    ($each_score, $each_pvalue) = @$each_score_ref;
		}
		else {
		    ($each_score, $each_pvalue) = (0, 1);
		}
		
		my ($style) = gendooCommon::score2style($each_pvalue, "list");

		print "  <td class=\"$style\" title=\"IG=$each_score, p-value=$each_pvalue\">";
		print "<br>";
#	    print $each_score;
		print join("\t", "", $each_score, $each_pvalue) if $debug == 2;
		print "</td>"."\n";
	    } 
	    print " </tr>"."\n";

	}
	print "</table>"."\n";

	print "<br>"."\n";

	print "<input name=\"submit\" type=\"submit\" value=\"Search\">"."\n";
	print "<input name=\"reset\" type=\"reset\" value=\"Reset\">"."\n";
	
	print "<br>"."\n";

	print "<hr>"."\n";
	print "\n";

	undef %sumscore;


#	print "</form>";

#    printFooter();
    }
}





sub initialize {
    my ($geneids_ref, $taxonomy) = @_;
    $file_genename = gendooConf::f_gene($taxonomy);
    $file_mesh     = gendooConf::f_mesh();
    $file_mesh2ja  = gendooConf::f_mesh2ja();

    %category = ( "C" => ["Disease", "disease"],
		  "D" => ["Chemicals", "chemical"],
		  "G" => ["Biological Phenomena", "biolphenom"],
		  "F" => ["Psychiatry and Psychology", "psycho"],
		  "A" => ["Anatomy", "anatomy"],
		  "B" => ["Organisms", "organism"] );

    my @geneids_pre = @$geneids_ref;
    my @geneids = gendooCommon::uniqArray(@geneids_pre);

    my $cat_ref = gendooConf::tax2category($taxonomy);
    my @cat = @$cat_ref;

    my $type_ref = gendooConf::tax2type($taxonomy);
    my @type = @$type_ref;

    return (\@geneids, \@cat, \@type);
}


sub catLink {
    my (@cat) = @_;    

    foreach $each_category (@cat) {
	my $cat_name_ref = $category{$each_category};
	my ($cat_title, $cat_link) = @$cat_name_ref;
	push @links, "<a href=\"\#$cat_link\">$cat_title</a>";
#	push @links, $page->a({href => "#".$cat_link}, $cat_title);
    }

    $link = join(" : ", @links);

    return($link);
}


sub printQueries {
    my (@geneids) = @_;

    my $geneid_grep = "(".join("|", @geneids).")";

    open (GENE, $file_genename) or die $!;
    my @lines_hit = grep { $_ =~ /^$geneid_grep\t/ } <GENE>;
    close (GENE);

    foreach $line_name (@lines_hit) {
        my ($id, $symbol, $desc, $name) = split(/\t/, $line_name);
	push @q_out, ({geneid => $id, symbol => $symbol, desc => $desc});

	$id2genename{$id} = $symbol;
    }

    return (\@q_out);
}


sub printScreen {
    my ($query, $link, $taxonomy) = @_;

    my $output;

    $template->process( "geneid2score.html",
			{ query    => $query,
			  link     => $link ,
		          taxonomy => $taxonomy },
			\$output );

    print encode('utf-8', $output);
}


sub createMeshDic {
    open (MESH, $file_mesh) or die $!;
    while (defined ($line_mesh = <MESH>)) {
        $line_mesh =~ s/\r//g;
        $line_mesh =~ s/\n//g;

        my ($meshid, $mesh_term, $mesh_tree) = split(/\t/, $line_mesh);
        $meshid2term{$meshid} = $mesh_term;
    }
    close (MESH);

    open (MESH2JA, $file_mesh2ja) or die $!;
    while (defined ($line_mesh2ja = <MESH2JA>)) {
	$line_mesh2ja =~ s/[\r\n]//g;

	my ($meshid, $ja) = split(/\t/, $line_mesh2ja);
	$ja =~ s/ＮＯＳ$//;
	$meshid2ja{$meshid} = $ja;
    }
    close (MESH2JA);
}


sub grepRsltPair {
    my ($each_cat, $type_ref, $taxonomy, $geneids_ref) = @_;

    my %sumscore;
    my %score;

    foreach $each_type (@$type_ref) {
	my $file_target = join("\.", "score", "gene", $taxonomy ,$each_type, $each_cat, "tab");
	my $id_search = join("\|", @$geneids_ref);

	print STDERR $file_target."\n" if $debug == 2;

	open (TARGET, "../data/".$file_target) or die $!;
	@lines_hit = grep { $_ =~ /^($id_search)\t/ } <TARGET>;
	close (TARGET);

	foreach $each_hit (@lines_hit) {
	    $each_hit =~ s/[\r\n]//g;

	    my ($geneid, $score, $pvalue, $meshid) = split(/\t/, $each_hit);

	    print join("\t", $geneid, $score, $pvalue, $meshid)."<br>"."\n" if $debug == 2;

	    if ($pvalue == 0) {
		$log = -1000;
	    }
	    else {
		$log = log($pvalue)/log(10);
	    }

	    $sumscore{$meshid} += $log;
	    $score{$meshid}{$geneid} = [$score, $pvalue];
	}
    }

    return (\%sumscore, \%score);
}




1;

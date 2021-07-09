#!/usr/bin/perl

# geneid2tree.pm
# Nakazato T.
# '08-08-21-Thu.    Ver. 0.1


package geneid2tree;

use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT=qw(call);

require "./gendooCommon.pm";
require "./gendooConf.pm";


my $debug = 1;

sub call {
    my ($geneids_ref, $category, $taxonomy) = @_;

    my (@geneids) = initialize($geneids_ref, $taxonomy);
    arrangeQueryData(\@geneids, $category, $taxonomy);

    htmlHeader();
    jsTreeHeader();
    readMeSH();
    extMeSHOut();
    compMeSH($category);
    printTree();
    printScore();
    jsTreeFooter();
    htmlBodyHead();
    printQueries(@geneids);
    linkToList(\@geneids, $taxonomy);
    print "<hr>"."\n";
    htmlBodyFoot();
}


### Data Arrangement

sub initialize {
    my ($geneids_ref, $taxonomy) = @_;
    my @geneids_pre = @$geneids_ref;
    my @geneids = gendooCommon::uniqArray(@geneids_pre);

    $file_genename = gendooConf::f_gene($taxonomy);
    $file_mesh = gendooConf::f_mesh();
    $file_meshja = gendooConf::f_mesh2ja();

    return (@geneids);
}

sub arrangeQueryData {
    my ($geneids_ref, $category, $taxonomy) = @_;

    my (@geneids) = @$geneids_ref;

    my $type_ref = gendooConf::tax2type($taxonomy);
    @type = @$type_ref;

    foreach $each_type (@type) {
	my $file_target = join("\.", "score", "gene", $taxonomy, $each_type, $category, "tab");
	my $id_search = join("\|", @geneids);

	open (TARGET, "../data/".$file_target) or die $!." $file_target ";
	@lines_hit = grep { $_ =~ /^($id_search)\t/ } <TARGET>;
	close (TARGET);

	$num_hit = scalar(@lines_hit);

	foreach $each_hit (@lines_hit) {
	    $each_hit =~ s/\r//g;
	    $each_hit =~ s/\n//g;

	    my ($geneid, $score, $pvalue, $meshid) = split(/\t/, $each_hit);

	   # $meshid2score{$meshid} += $score / $num_hit;
	    $meshid2score{$meshid} += $score;
	}
    }

#    %meshid2score / scalar(@lines_hit);
}


sub readMeSH {
#    $file_mesh = "data/mesh.term2tree.tab";
    open (MESH, $file_mesh) or die $!;
    while (defined ($line_mesh = <MESH>)) {
	$line_mesh =~ s/\r//g;
	$line_mesh =~ s/\n//g;

	my ($meshid, $mterm, $mtree_pre) = split(/\t/, $line_mesh);

	@mtreeids = split(/\|/, $mtree_pre);
	$treeid2term{$_} = $mterm foreach @mtreeids;
	$meshId2tree{$meshid} = $mtree_pre;
    }
    close (MESH);
}

sub extMeSHOut {
    foreach $each_mid ( keys (%meshid2score) ) {
	$mtree_out_pre = $meshId2tree{$each_mid};
	@each_mtreeids = split(/\|/, $mtree_out_pre);
	$treeid2score{$_} = $meshid2score{$each_mid} foreach @each_mtreeids;
    }

    undef %meshId2tree;
    undef %meshid2score;
}

sub compMeSH {
    my ($category) = @_;

    foreach $each_treeid (sort (keys (%treeid2score))) {
	if ($each_treeid =~ /^[^$category]/) {
	    delete $treeid2score{$each_treeid};
	    next;
	}

	while ($each_treeid =~ s/\.\d{3}$//) {
	    if ( exists ($treeid2score{$each_treeid})) {
		next;
	    }
	    else {
		$treeid2score{$each_treeid} = 0;
	    }
	}
    }
}

sub printTree {
    foreach $each_treeid (sort (keys (%treeid2score))) {
	my $mterm = $treeid2term{$each_treeid};

	$each_treeid =~ s/\.//g;

	if ($each_treeid =~ /^\w\d{2}$/) {
	    $treeid_parent = "root";
	}
	else {
	    $treeid_parent = $each_treeid;
	    $treeid_parent =~ s/\d{3}$//;
	}

	print "      var $each_treeid = new YAHOO.widget.TextNode(\"$mterm\", $treeid_parent, true);"."\n";
    }
}

sub printScore {
    foreach $each_treeid ( sort ( keys (%treeid2score))) {
	$each_score = $treeid2score{$each_treeid};
	$each_treeid =~ s/\.//g;

	if ($each_score == 0) {
	    $pvalue = 1;
	}
	else {
	    $pvalue = 10 ** (-82402 * $each_score - 0.94195);
	    $style = gendooCommon::score2style($pvalue, "tree");
	    print $each_treeid.".labelStyle = "."\"".$style."\""."\n";
	}
    }
}



### Visualization

sub htmlHeader {
    $page=CGI->new();
    print $page->header();
    print $page->start_html( -lang   => "en-US",
			     -title  => "Gendoo - MeSH tree view",
			     -style  => [{ -src => "../css/sam/treeview.css" },
					 { -src => "../gendoo.css" }],
			     -script => [{ -language => 'JavaScript',
					   -src => "../js/yahoo/yahoo-min.js"},
					 { -language => 'JavaScript',
					   -src => "../js/event/event-min.js"},
					 { -language => 'JavaScript',
					   -src => "../js/treeview/treeview-min.js"}]);
}

sub jsTreeHeader {

    print <<JSTREEHEADER;
<script type="text/javascript">
<!--
var tree;
    window.onload = function treeInit() {
	tree = new YAHOO.widget.TreeView("treeDiv1");
	var root = tree.getRoot();
JSTREEHEADER
    }

sub jsTreeFooter {
    print <<JSTREEFOOTER;
    tree.draw();
}

// -->
</script>

</head>
JSTREEFOOTER
}

sub printQueries {
    my (@geneids) = @_;

    print $page->h3("Query gene list");
    print "<table border>"."\n";

    my $geneid_grep = "(".join("|", @geneids).")";

    open (GENE, $file_genename) or die $!;
    my @lines_hit = grep { $_ =~ /^$geneid_grep\t/ } <GENE>;
    close (GENE);

    foreach $line_name (@lines_hit) {
        my ($id, $symbol, $desc, $name) = split(/\t/, $line_name);


        print <<GENENAME;
 <tr style="text-align: left;">
  <th>$id</th>
  <th>$symbol</th>
  <th>$desc</th>
  <th><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=DetailsSearch&Term=$id"><img src="../images/gd.gene.png" width=32 height=17 border=0 alt="Entrez Gene"></a></th>
 </tr>
GENENAME

    }
    print "</table>"."\n";
}

sub linkToList {
    my ($geneids_ref, $taxonomy) = @_;

    @geneids = @$geneids_ref;

    my $link_id;
    $link_id .= "geneid=".$_."&" foreach @geneids;
    $link_id =~ s/\&$//;
    my $link_list = "gendoo.cgi?".join("&", $link_id, "taxonomy=$taxonomy");
    print $page->p("&#8594; ".$page->a({href=>$link_list}, "High-scoring List"));
}

sub htmlBodyHead {
    print <<HTMLBODYHEAD;
<body>

<h1>
 <a href="../index.html">
  <img src="../images/gendoo.logo-s.png" border=0 width=222 height=51 alt="Gendoo">
 </a>
</h1> 

<!-- <h1><a href="../index.html">Gendoo</a></h1> -->

<h2>MeSH Treeview</h2>
HTMLBODYHEAD
}

sub htmlBodyFoot {
print <<HTMLBODYFOOT;
<div id="treeDiv1"></div>

<hr>
<p style="text-align: right;"><a href="http://dbcls.rois.ac.jp/">Database Center for Life Science</a></p>

</body>
</html>
HTMLBODYFOOT

}



1;



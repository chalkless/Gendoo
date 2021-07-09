#!/usr/bin/perl

# id2rslt.pm
# Nakazato T.
# '07-10-15-Mon.    Ver. 1
# '08-02-19-Tue.    Ver. 1.1



package id2rslt;

use Data::Dumper;
use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT = qw(call);

require "./gendooCommon.pm";

my $debug = 1;

$page = CGI->new();

if (@ARGV) {
    my ($geneid, $taxonomy) = @ARGV;
    push @genes, $geneid;
    call(\@genes);
    exit;
}


sub call {
    my ($geneid_ref, $taxonomy) = @_;

    print STDERR Dumper($geneid_ref) if ($debug == 2);

    htmlHeader();
    printPageTitle();
    @symbol_list = printGene($geneid_ref, $taxonomy);
    printLink();
    printTable($geneid_ref, $taxonomy, \@symbol_list);
    htmlFooter();
}


sub printCGI {
    print $page->header;
}

sub htmlHeader {
    print $page->start_html(-title => "Gendoo",
	                    -style => [{-src => "../gendoo.css"},
				       {-src => "../simpletree.css"}],
			    -script => {-language => "JAVASCRIPT",
					-src => "../simpletreemenu.js"});
}

sub printPageTitle {
    print $page->h1($page->a({href => "../gendoo.html"}, "Gendoo"));

    print $page->h2("Gene -> MeSH");
}


sub printLink {
    print join(" : ",
	       $page->a({href => "#disease"}, "Disease"),
	       $page->a({href => "#chemical"}, "Chemicals"),
	       $page->a({href => "#biolphenom"}, "Biological Phenomena"),
	       $page->a({href => "#anatomy"}, "Anatomy"),
	       $page->a({href => "#organism"}, "Organisms")
    );
    print $page->hr();
}

sub printGene {
    my ($geneid_ref, $taxonomy) = @_;

    @geneids = @$geneid_ref;

    print $page->h2("Query Genes");
    print "<table border>"."\n";

    my $geneid_grep = "(".join("|", @geneids).")";

    open (IDNAME, "data/id2name.$taxonomy.tab") or die $!;
    @lines_hit = grep { $_ =~ /^$geneid_grep\t/ } <IDNAME>;
    close (IDNAME);

    foreach $line_name (@lines_hit) {
	my ($id, $symbol, $desc, $name) = split(/\t/, $line_name);

print <<GENENAME;
 <tr style="text-align: left;">
  <th>$id</th>
  <th>$symbol</th>
  <th>$desc</th>
  <th><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=DetailsSearch&Term=$id">[NCBI]</a></th>
 </tr>
GENENAME

    push @symbol_list, $symbol;
    }

    print "</table>"."\n";
    print "<br>"."\n";

    return(@symbol_list);
}


sub printTable {
    my ($geneid_ref, $taxonomy, $symbol_ref) = @_;

    @geneids = @$geneid_ref;
    @symbols = @$symbol_ref;

    if ($debug == 2) {
	print STDERR "[geneid]".$_ foreach @geneids;
	print "[GeneID]\t".$geneid."\n";
    }

    $geneid_grep = "(".join("|", @geneids).")";

    my (@rslts) = grepScore($geneid_grep, $taxonomy);

    print "<form method=GET action=\"gendoo.cgi\">\n";
    print "<input name=\"taxonomy\" type=\"hidden\" value=\"$taxonomy\">";

    open (MESH, "gendoo.meshtree.html") or die $!;
    @meshtree = <MESH>;
    close (MESH);

    ### Disease
    print $page->h2($page->a({name => "disease"}, "Disease"));
    tableHeader(@geneids);
    @rslts_disease = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /C/ } @rslts;
    tableBody($taxonomy, \@rslts_disease, \@geneids);

    ### Chemicals
    print $page->h2($page->a({name => "chemical"}, "Chemicals"));
    tableHeader(@geneids);
    @rslts_chemical = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /D/ } @rslts;
    tableBody($taxonomy, \@rslts_chemical, \@geneids);

    ### Biological Phenomena
    print $page->h2($page->a({name => "biolphenom"}, "Biological Phenomena"));
    tableHeader(@geneids);
    @rslts_biol = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /G/ } @rslts;
    tableBody($taxonomy, \@rslts_biol, \@geneids);

    ### Anatomy
    print $page->h2($page->a({name => "anatomy"}, "Anatomy"));
    tableHeader(@geneids);
    @rslts_anatomy = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /A\d{2}/ } @rslts;
    tableBody($taxonomy, \@rslts_anatomy, \@geneids);

    ### Organisms
    print $page->h2($page->a({name => "organism"}, "Oragnisms"));
    tableHeader(@geneids);
    @rslts_organisms = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /B/ } @rslts;
    tableBody($taxonomy, \@rslts_organisms, \@geneids);
}

sub htmlFooter {

    print "</form>";
    print $page->hr();
    print "<p style=\"text-align: right\;\">Database Center for Life Science</p>";
    print $page->end_html;
}

sub tableHeader {
    my (@symbols) = @_;

print <<DHEADER;
<div class="rslt">

<!-- <div class="rslt_table" style="width: 600px; padding: auto 0px; left: 0px; position: absolute;"> -->

<table border>
 <tr>
  <th><br></th>
  <th>MeSH terms</th>
  <th>Link</th>
DHEADER

    foreach $each_symbol (@symbols) {
	print "<th>$each_symbol</th>\n";
	print "<!-- <th>p-value</th> -->\n";
    }
    print "</tr>\n";
}

sub grepScore {
    my ($geneid, $taxonomy) = @_;

    print STDERR $geneid if ($debug == 2);

    open (SCORE, "data/gene.mesh.score.arranged.$taxonomy.tab") or die $!;
    while (defined ($line_rslt = <SCORE>)) {
	if ($line_rslt =~ /^$geneid\t/) {
	    push @rslts, $line_rslt;
	}
    }
    close (SCORE);

    return (@rslts);
}

sub tableBody {
    my ($taxonomy, $rslts_ref, $geneid_ref) = @_;
    my (@mesh_list) = ();

    my (@rslts) = @$rslts_ref;
    my (@geneid) = @$geneid_ref;

    ### parse results
    foreach $each_rslt (@rslts) {
	$each_rslt =~ s/\r//;
	$each_rslt =~ s/\n//;

	my ($gene_id, $ig, $pvalue, $gene_name, $mesh, $meshid) = split(/\t/, $each_rslt);

	$gm2score{$gene_id}->{$mesh} = [$ig, $pvalue];
	push @mesh_list, $mesh;
    }

    my (@mesh_uniq) = uniqArray(@mesh_list);

    foreach $each_mesh (@mesh_uniq) {
	$mesh_link = $each_mesh;
	$mesh_link =~ s/\s/+/g;
	$mesh_link =~ s/^M://;

print <<DBODY1;
 <tr>
  <td><input name="mesh" type="checkbox" value="$each_mesh"></td>
  <td><a href="gendoo.cgi\?mesh=$mesh_link&taxonomy=$taxonomy">$each_mesh</a></td>
  <td><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=mesh&Cmd=DetailsSearch&Term=%22$mesh_link%22%5BMeSH+Terms%5D">[NCBI]</td>
DBODY1


	foreach $each_gene (@geneid) {

	    if (defined ($gm2score{$each_gene}->{$each_mesh})) {
		my $score_ref = $gm2score{$each_gene}->{$each_mesh};

		($ig_ret, $pvalue_ret) = @$score_ref;

		print STDERR $ig_ret."\t".$pvalue_ret."\n" if ($debug == 2);

		$style = gendooCommon::score2style($pvalue_ret);
	    } else {
		($ig_ret, $pvalue_ret) = (0, 1);
	        ($style) = "score16";
	    }

	    print "<td class=\"$style\">$ig_ret</td>"."\n";
	    print "<!-- <td>$pvalue_ret</td> -->"."\n";
        }

	print "</tr>"."\n";
    }
    print "</table>\n";
    print "<br>\n";
    print "<input name=\"submit\" type=\"submit\" value=\"Search\">\n";
    print "<input name=\"reset\" type=\"submit\" value=\"Reset\">\n";
#    print "</div>"."\n";    # <div class="rslt_table">

#    print " <div class=\"rslt_tree\" style=\"margin-left:600px\">"."\n";

#    @tree_category = grep { (($_ =~ /START Disease/) .. ($_ =~ /END Disease/)) } @meshtree;

#    print @tree_category;

#    print " </div>"."\n";
#    print "</div>"."\n";    # <div class="rslt">
    print "<br><br><br>\n";
}


sub uniqArray {
    my (@array_pre) = @_;

    @array_uniq = ();
    %hash = ();
    if (0) {
    foreach $element (@array_pre) {
	if (defined ($hash{$_})) {

	} else {
	    $hash{$_} = 1 foreach (@array_pre);
	    push @array_uniq, $element;
	}
    }
}

    foreach $element (@array_pre) {
	if (defined ($hash{$element})) {

	} 
	else {
	    $hash{$element} = 1;
	    push @array_uniq, $element;
	}
    }

    return @array_uniq;
}


1;


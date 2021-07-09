#!/usr/bin/perl -w

# mesh2omim.pm
# Nakazato T.
# '07-10-16-Tue.    Ver. 0
# '07-10-26-Fri.    Ver. 0.1    category -> merge
# '07-11-01-Thu.    Ver. 0.2    for omim

package mesh2omim;

use Data::Dumper;
use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT = qw(call);

require "./gendooCommon.pm";

my $debug = 1;

$page = CGI->new();

if (@ARGV) {
    my ($mesh) = @ARGV;
    call($mesh);
    exit;
}


sub call {
    my ($mesh_ref) = @_;

    print "[mesh2gene]\t".Dumper($mesh_ref)."\n" if ($debug == 2);

    htmlHeader();
    printPageTitle();
    showQuery($mesh_ref);
    formHeader();
    tableHeader($mesh_ref);
    my (@rslts) = grepMeSH($mesh_ref);
    tableBody(\@rslts, $mesh_ref);
    tableFooter();
}

sub printCGI {
    print $page->header();
}

sub htmlHeader {
    print $page->start_html(-title => "Gendoo OMIM",
	                    -style => {src => "../gendoo.css"});
}

sub printPageTitle {
    print $page->h1($page->a({href => "../gendoo.omim.html"},"Gendoo OMIM"));
    print $page->h2("MeSH -> OMIM");
}

sub showQuery {
    my ($mesh_ref) = @_;

    print STDERR Dumper($mesh_ref) if ($debug == 2);

    @mesh_list = @$mesh_ref;

    print "<p>"."\n";
    print "Query Keywords:<br>";
    print "<table border>\n";

    foreach $each_mesh (@mesh_list) {
        $mesh_link = $each_mesh;
        $mesh_link =~ s/\s/+/g;
        $mesh_link =~ s/^M://;

	print "<tr>"."\n";
	print "<td>$each_mesh</td>"."\n";
	print "<td><a href=\"http://www.ncbi.nlm.nih.gov/sites/entrez?Db=mesh&Cmd=DetailsSearch&Term=%22$mesh_link%22%5BMeSH+Terms%5D\">[NCBI]</td>"."\n";
	print "</tr>"."\n";
    }

    print "</table>"."\n";
    print "<br><br>"."\n";
}


sub formHeader {
#    my () = @_;

    print "<form method=GET action=\"gendoo.omim.cgi\">\n";
#    print "<input name=\"taxonomy\" type=\"hidden\" value=\"$taxonomy\">";
}

sub tableHeader {
    my ($mesh_ref) = @_;

    @mesh = @$mesh_ref;

    print <<THEADER;
<table border>
 <tr>
  <th><br></th>
  <th>MIMID</th>
  <th>OMIM</th>
  <th>Link</th>
THEADER

    foreach $each_mesh (@mesh) {
	print "<th>$each_mesh</th>";
	print "<!-- <th>p-value</th> -->";
    }
    print "</tr>";
}

sub grepMeSH {
    my ($mesh_ref) = @_;

    @mesh = @$mesh_ref;

    $mesh_grep = "(".join("|", @mesh).")";

    open(MESH, "data/omim.mesh.score.tab") or die $!;
    while (defined ($line_mesh = <MESH>)) {
	if ($line_mesh =~ /\t$mesh_grep\t/) {
	    print STDERR $line_mesh if ($debug == 2);
	    push @rslts, $line_mesh;
	}
    }
    close(MESH);
    return (@rslts);
}

sub tableBody {
    my ($rslts_ref, $mesh_ref) = @_;

    my (@rslts) = @$rslts_ref;
    my (@mesh) = @$mesh_ref;

    @rslts_gene = grep {@ele = split(/\t/, $_); $F[5] == 1} @rslts;
    @rslts_phenotype = grep {@ele = split(/\t/, $_); $F[5] != 1} @rslts;

    foreach $each_rslt (@rslts) {
	$each_rslt =~ s/\r//;
	$each_rslt =~ s/\n//;

	my ($omim_id, $ig, $pvalue, $omim_name, $mesh_tmp, $mesh_category) = split(/\t/, $each_rslt);

	$gm2score{$omim_id}->{$mesh_tmp} = [$ig, $pvalue];
	push @omim_list, [$omim_id, $omim_name];
	push @omimid_list, $omim_id;
	push @name_list, $omim_name;
    }

    my (@omimlist_uniq) = gendooCommon::uniqArray(@omim_list);

    foreach $each_omimlist (@omimlist_uniq) {
	($each_omimid, $each_name) = @$each_omimlist;

	print <<DBODY1;
 <tr>
  <td><input name="omim" type="checkbox" value="$each_name"></td>
  <td>$each_omimid</td>
  <td>$each_name</td>
  <td><a href="http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=$each_omimid">[NCBI]</a></td>
DBODY1


        foreach $each_mesh (@mesh) {

	if (defined ($gm2score{$each_omimid}->{$each_mesh})) {
	    my $score_ref = $gm2score{$each_omimid}->{$each_mesh};

	    ($ig_ret, $pvalue_ret) = @$score_ref;

	    print STDERR $ig_ret."\t".$pvalue_ret."\n" if ($debug == 2);

	    $style = gendooCommon::score2style($pvalue_ret);
	} else {
	    ($ig_ret, $pvalue_ret) = (0, 1);
	    $style = "score16";
	}

	print "<td class=\"$style\">$ig_ret</td>"."\n";
	print "<!-- <td>$pvalue_ret</td> -->"."\n";
    }

	print "</tr>"."\n";
    }



}

sub tableFooter {
    print "</table>\n";
    print "<br>\n";
    print "<input name=\"submit\" type=\"submit\" value=\"Search\">\n";
    print "<input name=\"reset\" type=\"submit\" value=\"Reset\">\n";
    print "<br><br><br>\n";
    print "</form>"."\n";

print $page->hr();
    print "<p style=\"text-align: right\;\">Database Center for Life Science</p>";
    print $page->end_html();
}

1;

#!/usr/bin/perl -w

# mesh2gene.pm
# Nakazato T.
# '07-10-16-Tue.    Ver. 0
# '07-10-26-Fri.    Ver. 0.1    category -> merge


package mesh2gene;

use Data::Dumper;
use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT = qw(call);

require "./gendooCommon.pm";

my $debug = 1;

$page = CGI->new();

if (@ARGV) {
    my ($mesh, $taxonomy) = @ARGV;
    call($mesh, $taxonomy);
    exit;
}


sub call {
    my ($mesh_ref, $taxonomy) = @_;

    print "[mesh2gene]\t".$mesh."\n" if ($debug == 2);

    htmlHeader();
    printPageTitle();
    showQuery($mesh_ref);
    formHeader($taxonomy);
    tableHeader($mesh_ref);
    my (@rslts) = grepMeSH($mesh_ref, $taxonomy);
    tableBody(\@rslts, $taxonomy, $mesh_ref);
    tableFooter();
}

sub printCGI {
    print $page->header();
}

sub htmlHeader {
    print $page->start_html(-title => "Gendoo",
	                    -style => {src => "../gendoo.css"});
}

sub printPageTitle {
    print $page->h1($page->a({href => "../gendoo.html"},"Gendoo"));
    print $page->h2("MeSH -> Gene");
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
    my ($taxonomy) = @_;

    print "<form method=GET action=\"gendoo.cgi\">\n";
    print "<input name=\"taxonomy\" type=\"hidden\" value=\"$taxonomy\">";
}

sub tableHeader {
    my ($mesh_ref) = @_;

    @mesh = @$mesh_ref;

    print <<THEADER;
<table border>
 <tr>
  <th><br></th>
  <th>GeneID</th>
  <th>Gene Name</th>
  <th>Link</th>
THEADER

    foreach $each_mesh (@mesh) {
	print "<th>$each_mesh</th>";
	# print "<th>p-value</th>";
    }
    print "</tr>";
}

sub grepMeSH {
    my ($mesh_ref, $taxonomy) = @_;

    @mesh = @$mesh_ref;

    $mesh_grep = "(".join("|", @mesh).")";

    open(MESH, "data/gene.mesh.score.arranged.$taxonomy.tab") or die $!;
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
    my ($rslts_ref, $taxonomy, $mesh_ref) = @_;

    my (@rslts) = @$rslts_ref;
    my (@mesh) = @$mesh_ref;

    foreach $each_rslt (@rslts) {
	$each_rslt =~ s/\r//;
	$each_rslt =~ s/\n//;

	my ($geneid, $ig, $pvalue, $gene_name, $mesh_tmp, $mesh_category) = split(/\t/, $each_rslt);

	$gm2score{$geneid}->{$mesh_tmp} = [$ig, $pvalue];
	push @gene_list, [$geneid, $gene_name];
	push @geneid_list, $geneid;
	push @name_list, $gene_name;
    }

    my (@geneid_uniq) = gendooCommon::uniqArray(@geneid_list);
    # print STDERR "$_ " foreach @geneid_uniq;
    my (@name_uniq) = gendooCommon::uniqArray(@name_list);

    foreach $each_geneid (@geneid_uniq) {
	($each_name) = shift @name_uniq;

	print <<DBODY1;
 <tr>
  <td><input name="geneid" type="checkbox" value="$each_geneid"></td>
  <td>$each_geneid</td>
  <td>$each_name</td>
  <td><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=DetailsSearch&Term=$geneid">[NCBI]</a></td>
DBODY1


        foreach $each_mesh (@mesh) {

	if (defined ($gm2score{$each_geneid}->{$each_mesh})) {
	    my $score_ref = $gm2score{$each_geneid}->{$each_mesh};

	    ($ig_ret, $pvalue_ret) = @$score_ref;

	    print STDERR $ig_ret."\t".$pvalue_ret."\n" if ($debug == 2);

	    $style = gendooCommon::score2style($pvalue_ret);
	} else {
	    ($ig_ret, $pvalue_ret) = (0, 1);
	    $style = "score16";
	}

	print "<td class=\"$style\">$ig_ret</td>"."\n";
	# print "<td>$pvalue_ret</td>"."\n";
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

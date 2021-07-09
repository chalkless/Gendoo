#!/usr/bin/perl -w

# meshName2list.pm
# Nakazato T.
# '07-10-16-Tue.    Ver. 0      name2list (original)
# '07-10-24-Wed.    Ver. 0.1    meshName2list
# '07-10-31-Wed.    Ver. 0.2    omimName2list

package omimName2list;

use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT = qw(call);

use Data::Dumper;

require "./gendooCommon.pm";


my $debug = 1;

$page = CGI->new();

if (@ARGV) {
    my ($name) = @ARGV;
    call($name);
    exit;
}

sub call {
    my ($name_ref) = @_;

    print STDERR "[name2list]\t".Dumper($name_ref) if ($debug == 2);


    htmlHeader();
    printPageTitle();
    showQuery($name_ref);

    my (@name_candidate) = grepName($name_ref);
    my ($name_gene_ref, $name_phenotype_ref) = devCategory(@name_candidate);

    ### Gene
    tableHeader("Gene");
    printRslt($name_gene_ref, "Gene");
    tableFooter();

    ### Phenotype
    tableHeader("Phenotype");
    printRslt($name_phenotype_ref, "Phenotype");
    tableFooter();

    pageFooter();
}



sub printCGI {
    print $page->header();
}


sub htmlHeader {
    print $page->start_html(-title => "Gendoo OMIM",
	                    -style => { src => "../gendoo.css" });
}


sub printPageTitle {
    print $page->h1($page->a({href => "../gendoo.omim.html"}, "Gendoo OMIM"));
    print $page->h2("Candidate OMIM Entries List");

    print "<form method=\"GET\" action=\"gendoo.omim.cgi\">"
}

sub tableHeader {
    my ($category) = @_;

    print $page->h3("$category");


print <<THEADER;
<table border>
 <tr>
  <th><br></th>
  <th>OMIM</th>
  <th>Description</th>
  <th>Link</th>
  <th>Synonyms</th>
 </tr>
THEADER
}

sub showQuery {
    my ($name_ref) = @_;

    @names = @$name_ref;

    print "<p>Your query term:<br>";
    print "<span style=\"font-weight: bold;\">$_</span><br>\n" foreach @names;
    print "</p>";

    print $page->br();
}

sub grepName {
    my ($name_ref) = @_;

    my (@name) = @$name_ref;

    open(NAME, "data/omim.name.tab") or die $!;

    $name_grep = "(".join("|",@name).")";
    @name_candidates = grep { $_ =~ /$name_grep/i } <NAME>;
    close(NAME);

    return (@name_candidate);
}

sub devCategory {
    my (@name_candidate) = @_;

    foreach $each_name (@name_candidates) {
	@ele = split(/\t/, $each_name);

	if (($ele[1] == 1) or ($ele[1] == 4)) {
	    push @name_gene, $each_name;
	}
	else {
	    push @name_phenotype, $each_name;
	}
    }

    return(\@name_gene, \@name_phenotype);
}

sub printRslt {
    my ($name_ref, $category) = @_;

    @name_print = @$name_ref;

    foreach $each_name_print (@name_print) {
	my ($omimid, $type, $symbol, $desc, $name_other) = split(/\t/, $each_name_print);

	$name_other =~ s/\|/<br>\n/g;

#	$mesh_link = $symbol;
#	$mesh_link =~ s/\s/+/g;

print <<GENENAME;
 <tr>
  <td><input name="omim" type="checkbox" value="$symbol"></td>
  <td><a href="gendoo.omim.cgi\?omim=$symbol">$symbol</a></td>
  <td>$desc</td>
  <td><a href="http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=$omimid">[NCBI]</a></td>
  <td>$name_other</td>
 </tr>
GENENAME
    }
}

sub tableFooter {
    print "</table>\n";
    print $page->br();
    print $page->br();
    print "<input name=\"submit\" type=\"submit\" value=\"Search\">";
    print "<input name=\"reset\" type=\"reset\" value=\"Reset\">";
    print $page->br();
    print $page->br();
}

sub pageFooter {
    print "</form>"."\n";
    print $page->hr();
    print "<p style=\"text-align: right;\">Database Center for Life Science</p>";

    print $page->end_html();
}

1;

#!/usr/bin/perl -w

# meshName2list.pm
# Nakazato T.
# '07-10-16-Tue.    Ver. 0      name2list (original)
# '07-10-24-Wed.    Ver. 0.1    meshName2list

package meshName2list;

use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT = qw(call);

require "./gendooCommon.pm";


my $debug = 1;

$page = CGI->new();

if (@ARGV) {
    my ($name, $taxonomy) = @ARGV;
    call($name);
    exit;
}

sub call {
    my ($name_ref, $taxonomy) = @_;

    print "[name2list]\t".$name."\n" if ($debug == 2);


    htmlHeader();
    printPageTitle();
    showQuery($name_ref);
    tableHeader();
    grepName($name_ref, $taxonomy);
    tableFooter();
}

sub printCGI {
    print $page->header();
}


sub htmlHeader {
    print $page->start_html(-title => "Gendoo",
	                    -style => { src => "../gendoo.css" });
}


sub printPageTitle {
    print $page->h1($page->a({href => "../gendoo.html"}, Gendoo));
    print $page->h2("Candidate MeSH terms List");
}

sub tableHeader {
print <<THEADER;
<table border>
 <tr>
  <th>MeSH term</th>
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
}

sub grepName {
    my ($name_ref, $taxonomy) = @_;

    my (@name) = @$name_ref;

    open(NAME, "data/mesh.name.tab") or die $!;

    $name_grep = "(".join("|",@name).")";
    @name_candidates = grep { $_ =~ /$name_grep/i } <NAME>;
    close(NAME);

    foreach $each_name_candidate (@name_candidates) {
	my ($mid, $term, $name_other, $treeid) = split(/\t/, $each_name_candidate);

	$name_other =~ s/\|/<br>\n/g;

	$mesh_link = $term;
	$mesh_link =~ s/\s/+/g;

print <<GENENAME;
 <tr>
  <td><a href="gendoo.cgi\?mesh=$term\&taxonomy=$taxonomy">$term</a></td>
  <td><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=mesh&Cmd=DetailsSearch&Term=%22$mesh_link%22%5BMeSH+Terms%5D">[NCBI]</a></td>
  <td>$name_other</td>
 </tr>
GENENAME
    }
}

sub tableFooter {
print "</table>\n";

print $page->hr();
print "<p style=\"text-align: right;\">Database Center for Life Science</p>";

print $page->end_html();
}

1;

#!/usr/bin/perl -w

# name2list.pm
# Nakazato T.
# '07-10-16-Tue.    Ver. 0

package name2list;

use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT = qw(call);

my $debug = 1;

$page = CGI->new();

if (@ARGV) {
    my ($name, $taxonomy) = @ARGV;
    call($name, $taxonomy);
    exit;
}

sub call {
    my ($name_ref, $taxonomy) = @_;

    @name = @$name_ref;

    htmlHeader();
    printPageTitle();
    showQuery(@name);
    tableHeader($taxonomy);
    grepName(\@name, $taxonomy);
    tableFooter();
}

sub printCGI {
    print $page->header();
}


sub htmlHeader {
    print $page->start_html(-title => "Gendoo",
	                    -style => { src => "../gendoo.css" } );
}


sub printPageTitle {
    print $page->h1($page->a({href => "../gendoo.html"}, Gendoo));
    print $page->h2("Candidate Gene List");
}

sub tableHeader {
    my ($taxonomy) = @_;

print <<THEADER;
<form method="GET" action="gendoo.cgi">
<input name="taxonomy" type="hidden" value="$taxonomy">

<table border>
 <tr>
  <th><br></th>
  <th>GeneID</th>
  <th>Link</th>
  <th>Gene Symbol</th>
  <th>Description</th>
  <th>Synonyms</th>
 </tr>
THEADER
}

sub showQuery {
    my (@name) = @_;

    print "<p>Your query term:<br>\n";
    print "<span style=\"font-weight: bold;\">$_</span><br>\n" foreach @name;
    print "</p>";
}

sub grepName {
    my ($name_ref, $taxonomy) = @_;

    @name = @$name_ref;

    open(NAME, "data/id2name.$taxonomy.tab") or die $!;
    foreach $each_name (@name) {
	@name_candidates = grep { $_ =~ /$each_name/i } <NAME>;

	foreach $each_name_candidate (@name_candidates) {
	    my ($geneid, $symbol, $desc, $name_other) = split(/\t/, $each_name_candidate);

	    $name_other =~ s/\|/<br>\n/g;

print <<GENENAME;
 <tr>
  <td><input name="geneid" type="checkbox" value="$geneid"></td>
  <td><a href="gendoo.cgi\?geneid=$geneid&taxonomy=$taxonomy">$geneid</a></td>
  <td><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=DetailsSearch&Term=$geneid">[NCBI]</a></td>
  <td>$symbol</td>
  <td>$desc</td>
  <td>$name_other</td>
 </tr>
GENENAME
	}
    }
    close(NAME);
}

sub tableFooter {
print "</table>\n";
print "<br><br>\n";
print "<input name=\"submit\" type=\"submit\" value=\"Search\">"."\n";
print "<input name=\"reset\" type=\"reset\" value=\"Reset\">"."\n";

print "</form>"."\n";

print $page->hr();
print "<p style=\"text-align: right;\">Database Center for Life Science</p>";

print $page->end_html();
}

1;

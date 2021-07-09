#!/usr/bin/perl -w

# genename2list.pm
# Nakazato T.
# '08-07-16-Wed.    Ver. 0.1
# '09-01-28-Wed.    Ver. 0.2    multiple species


package genename2list;

use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT=qw(call);

require "./gendooConf.pm";


my $debug = 1;

$page=CGI->new();

sub call {
    my ($name_ref, $taxonomy) = @_;

    my @genenames = @$name_ref;

    $file_genename = gendooConf::f_gene($taxonomy);

    htmlTitle();
    showQuery(\@genenames, $taxonomy);

    print "<br><br>"."\n";

### Show Candidate Genes

    printTableHeader();

    print STDERR $file_genename."\n" if $debug == 2;

    open (NAME, $file_genename) or die $!;
    foreach $each_name (@genenames) {
	@name_candidates = grep {$_ =~ /$each_name/i } <NAME>;

	foreach $each_name_candidate (@name_candidates) {
	    my ($geneid, $symbol, $desc, $synonym, $type) = split(/\t/, $each_name_candidate);
	    $synonym =~ s/\|/<br>\n/g;

	    print <<GENENAME;
 <tr>
  <td><input name="geneid" type="checkbox" value="$geneid"></td>
  <td><a href="gendoo.cgi\?geneid=$geneid&taxonomy=$taxonomy">$geneid</a></td>
  <td><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=DetailsSearch&Term=$geneid">[NCBI]</a></td>
  <td>$symbol</td>
  <td>$desc</td>
  <td>$synonym</td>
 </tr>
GENENAME
	}

    }
    close (NAME);




print <<TFOOTER;
</table>


<input type="button" onClick="allcheck(this.form, true)" value="Check All">
<input type="button" onClick="allcheck(this.form, false)" value="Uncheck All">


<br><br>
<input name="taxonomy" type="hidden" value="$taxonomy">

<input name=\"submit\" type=\"submit\" value=\"Search\">
<input name=\"reset\" type=\"reset\" value=\"Reset\">

</form>
TFOOTER




    print $page->end_html();
}

sub htmlTitle {
    print $page->header();
    print $page->start_html(-title => "Gendoo",
			    -script => { -language => 'JavaScript', -src => '../gendoo.my.js' },
			    -style => { src => "../gendoo.css" } );
    print $page->h1($page->a({href => "../index.html"},
			     $page->img({ src => "../images/gendoo.logo-s.png",
					           border => 0,
                                 width  => 222,
                                 height => 51,
					  alt    => "Gendoo"})));
#    print $page->h1($page->a({href => "../index.html"}, "Gendoo"))."\n";
    print $page->h2("Candidate Gene List");
}

sub showQuery {
    my ($genenames_ref, $taxonomy) = @_;

    my (@genenames) = @$genenames_ref;

    my ($genename_out) = join("\|", @genenames);

    print <<QUERY;
<form method="GET" action="gendoo.cgi">
 Your Query: <input name="genename" type="text" size="50" value="$genename_out">
 <input name="taxonomy" type="hidden" value="$taxonomy">
 <input name="submit" type="submit" value="Search Again">
 <input name="reset"  type="reset"  value="Reset">
</form>
QUERY
}

sub printTableHeader {


print <<THEADER;
<form method="GET" action="gendoo.cgi">

<input type="button" onClick="allcheck(this.form, true)" value="Check All">
<input type="button" onClick="allcheck(this.form, false)" value="Uncheck All">

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


1;


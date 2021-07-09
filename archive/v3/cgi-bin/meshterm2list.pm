#!/usr/bin/perl

# meshterm2list.pm
# Nakazato T.
# '08-08-18-Mon.    Ver. 0


package meshterm2list;

use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT=qw(call);

require "./gendooConf.pm";


my $debug = 1;

$page=CGI->new();

sub call {
    my ($term_ref, $taxonomy) = @_;

    initialize();

    my @meshterms = @$term_ref;

    print $page->header();
    print $page->start_html(-title => "Gendoo",
			    -style => { src => "../gendoo.css"} );
    print $page->h1($page->a({href => "../index.html"},
			     $page->img({ src => "../images/gendoo.logo-s.png",
					           border => 0,
                                 width  => 222,
                                 height => 51,
					  alt    => "Gendoo"})));

#    print $page->h1($page->a({href => "../index.html"}, "Gendoo"))."\n";
    print $page->h2("Candidate MeSH Term List");


    showQuery(\@meshterms, $taxonomy);

    listQuery(\@meshterms, $taxonomy);

    print $page->end_html();

}



sub showQuery {
    my ($meshterms_ref, $taxonomy) = @_;

    my (@meshterms) = @$meshterms_ref;

    my ($meshterms_out) = join("\|", @meshterms);

    print <<QUERY;
<form method="GET" action="gendoo.cgi">
 Your Query: <input name="mesh" type="text" size="50" value="$meshterms_out">
 <input name="taxonomy" type="hidden" value="$taxonomy">
 <input name="submit" type="submit" value="Search Again">
 <input name="reset"  type="reset"  value="Reset">
</form>

<br><br>

QUERY

}


sub listQuery {
    my ($meshterms_ref, $taxonomy) = @_;

    my (@meshterms) = @$meshterms_ref;

    open (TERM, $file_mesh) or die $!;
    foreach $each_term (@meshterms) {
	@term_candidates = grep { $_ =~ /$each_term/i } <TERM>;
    }
    close (TERM);

    print <<THEADER;
<form method="GET" action="gendoo.cgi">
<input name="taxonomy" type="hidden" value="$taxonomy">
THEADER

	foreach $each_category_ref (@categories) {

	    my ($each_category, $each_title) = @$each_category_ref;

	    print <<TBODY;

<h3>$each_title</h3>

 <table border>
  <tr>
   <th><br></th>
   <th>MeSH term</th>
   <th>Link</th>
  </tr>
TBODY


	    foreach $each_term_candidate (@term_candidates) {
		my ($meshid, $term, $treeid) = split(/\t/, $each_term_candidate);
		if ($treeid =~ /$each_category/) {
		    print <<MESHTERM;
 <tr>
  <td><input name="meshid" type="checkbox" value="$meshid"></td>
  <td><a href="gendoo.cgi\?meshid=$meshid&taxonomy=$taxonomy">$term</a></td>
  <td><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?db=mesh&term=%22$term%22">[NCBI]</a></td>
 </tr>
MESHTERM
		}
   	}

	    print <<TFOOTER;
</table>
<br>
<input name="submit" type="submit" value="Search">
<input name="reset" type="reset" value="Reset">

<br><br>
<hr>
<br>
TFOOTER
	}

    print "</form>";
}


sub initialize {
    $file_mesh = gendooConf::f_mesh();
    @categories = ( [ "C", "Diseases" ],
		    [ "D", "Chemicals and Drugs" ],
		    [ "G", "Biological Phenomena" ],
		    [ "A", "Anatomy" ],
		    [ "B", "Organisms" ] );
}



1;

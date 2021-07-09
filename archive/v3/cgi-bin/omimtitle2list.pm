#!/usr/bin/perl

# omimtitle2list.pm
# Nakazato T.
# '08-09-01-Mon.    Ver. 0.1


package omimtitle2list;

use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT=qw(call);

require "./gendooCommon.pm";
require "./gendooConf.pm";

my $debug = 1;

$page = CGI->new();

sub call {
    my ($name_ref) = @_;

    my @names = @$name_ref;

    $file_omim    = gendooConf::f_omim();
    $file_omim2ja = gendooConf::f_omim2ja();

    createOmim2Ja();

    htmlTitle();
    showQuery(@names);

    print "<br><br>"."\n";

    printTableHeaderIntro();

    open (JA, $file_omim2ja) or die $!;
    $name_search = join("\|", @names);
    @line_cand_fromJa = grep { $_ =~ /($name_search)/i } <JA>;
    close (JA);

#    print STDERR $name_search;
#    print STDERR scalar(@line_cand_fromJa);

    foreach $each_line_cand (@line_cand_fromJa) {
	@ele = split(/\t/, $each_line_cand);
	$name_search .= "|".$ele[0];
    }

    open (NAME, $file_omim) or die $!;
#    $name_search = join("\|", @names);
    @name_candidates = grep {$_ =~ /($name_search)/i } <NAME>;
    close (NAME);

# Sequence Known, Locus Known, Phenotype only

    @name_seq = grep { $_ =~ /[14]$/ } @name_candidates;
    # print STDERR "[seq known] ".$_."\n" foreach @name_seqs;

    @name_locus = grep { $_ =~ /5$/ } @name_candidates;

    @name_phenotype = grep { $_ =~ /[03]$/ } @name_candidates;

    foreach $each_name_ref (["Phenotype", \@name_phenotype],
		            ["Locus known", \@name_locus],
			    ["Disease relevant gene", \@name_seq]) {
#    foreach $each_name_ref (["Gene", \@name_seq],
#			    ["Locus", \@name_locus],
#			    ["Phenotype", \@name_phenotype]) {
	my ($title, $each_rslt_ref) = @$each_name_ref;

	print $page->h2($title);

	printRslt($each_rslt_ref);

	print "<hr>"."\n";
    }

    print "</form>";

    print "<p style=\"text-align: right;\"><a href=\"http://dbcls.rois.ac.jp/\">Database Center for Life Science</a></p>";

    print $page->end_html();

}


sub printRslt {
    my ($name_candidates_ref) = @_;

    @name_candidates = @$name_candidates_ref;

    printTableHeader();

    foreach $each_name_candidate (@name_candidates) {
	$each_name_candidate =~ s/\r//;
	$each_name_candidate =~ s/\n//;

	print STDERR $each_name_candidate."\n" if $debug == 2;
	my ($omimid, $symbol, $desc, $synonym, $status) = split(/\t/, $each_name_candidate);
	$synonym =~ s/\|/<br>\n/g;

	$ja = $omimid2ja{$omimid};

	print <<OMIMNAME;
 <tr>
  <td><input name="omimid" type="checkbox" value="$omimid"></td>
  <td><a href="gendoo.cgi?omimid=$omimid&taxonomy=human">$omimid</a></td>
  <td><a href="http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=$omimid">[NCBI]</a></td>
  <td>$symbol</td>
  <td>$desc</td>
  <td>$synonym</td>
  <td>$ja</td>
 </tr>
OMIMNAME

    }

    printTableFooter();
}



sub htmlTitle {
#    print $page->header();

    print "content-type: text/html; charset=utf-8\n\n";
    print $page->start_html(-title  => "Gendoo",
			    -script => { -language => 'JavaScript', -src => '../gendoo.my.js'  },
			    -style  => { src => "../gendoo.css"} );
#    print $page->h1($page->a({href => "../index.html" }, "Gendoo"))."\n";

    print $page->h1($page->a({href => "../index.html"},
			     $page->img({ src => "../images/gendoo.logo-s.png",
					           border => 0,
                                 width  => 222,
                                 height => 51,
					  alt    => "Gendoo"})));

    print $page->h2("Candidate OMIM Entry List");
}

sub createOmim2Ja {
    open (OMIM2JA, $file_omim2ja) or die $!;
    while (defined ($line_omim2ja = <OMIM2JA>)) {
	$line_omim2ja =~ s/[\r\n]//g;

	my ($omimid, $ja, $alias, $ev) = split(/\t/, $line_omim2ja);
	my ($ja_out) = $ja;
	if (($alias ne "-") and ($alias ne "")) {
	    $ja_out = join("\|", $ja, $alias);
	}
	$omimid2ja{$omimid} = $ja_out;
    }
    close (OMIM2JA);
}

sub showQuery {
    my (@names) = @_;

    my $name_out = join("\|", @names);

    print <<QUERY;
<form method="GET" action="gendoo.cgi">
 Your Query: <input name="omim" type="text" size="50" value="$name_out">
 <input name="taxonomy" type="hidden" value="human">
 <input name="submit" type="submit" value="Search Again">
 <input name="reset"  type="reset"  value="Reset">
</form>
QUERY
}

sub printTableHeaderIntro {
    print <<THEADERINTRO;
<form method="GET" action="gendoo.cgi">
<input name="taxonomy" type="hidden" value="human">
THEADERINTRO
}

sub printTableHeader {
    print <<THEADER;

<input type="button" onClick="allcheck(this.form, true)" value="Check All">
<input type="button" onClick="allcheck(this.form, false)" value="Uncheck All">

<table border>
 <tr>
  <th><br></th>
  <th>OMIM ID</th>
  <th>Link</th>
  <th>Symbol</th>
  <th>Description</th>
  <th>Synonyms</th>
  <th>Japanese</th>
 </tr>
THEADER
}

sub printTableFooter {
    print <<TFOOTER;
</table>

<br>

<input type="button" onClick="allcheck(this.form, true)" value="Check All">
<input type="button" onClick="allcheck(this.form, false)" value="Uncheck All">

<br><br>

<input name="submit" type="submit" value="Search">
<input name="reset"  type="reset"  value="Reset">

TFOOTER
}


1;


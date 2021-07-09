#!/usr/bin/perl -w

# omim2mesh.pm
# Nakazato T.
# '07-10-15-Mon.    Ver. 1
# '07-10-31-Wed.    Ver. 1.1    for omim


package omim2mesh;

use Data::Dumper;
use CGI;
use Exporter;
@ISA=(Exporter);
@EXPORT = qw(call);

require "./gendooCommon.pm";

my $debug = 1;

$page = CGI->new();

if (@ARGV) {
    my ($omim) = @ARGV;
    push @genes, $geneid;
    call(\@genes);
    exit;
}


sub call {
    my ($omim_ref) = @_;

    print STDERR "[omim2mesh]\n".Dumper($omim_ref) if ($debug == 2);

    htmlHeader();
    printPageTitle();
    ($symbol_ref, $omimids_ref) = printGene($omim_ref);
    printLink();
    printTable($omim_ref, $symbol_ref, $omimids_ref);
    htmlFooter();
}


sub printCGI {
    print $page->header;
}

sub htmlHeader {
    print $page->start_html(-title => "Gendoo OMIM",
	                    -style => {-src => "../gendoo.css"});
}

sub printPageTitle {
    print $page->h1($page->a({href => "../gendoo.omim.html"}, "Gendoo OMIM"));

    print $page->h2("OMIM -> MeSH");
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
    my ($omim_ref) = @_;

    @omim = @$omim_ref;
    @symbol_list = ();
    @id_list = ();

    print $page->h2("Query OMIM Entries");
    print "<table border>"."\n";

    print STDERR "[printOmim]\n".Dumper(@omim) if ($debug == 2);

    my $omim_grep = "(".join("|", @omim).")";

    print STDERR $omim_grep."\n" if ($debug == 2);

    open (IDNAME, "data/omim.name.tab") or die $!;
    @lines_hit = grep {	@ele = split(/\t/,$_) ;	$ele[2] =~ /^$omim_grep$/ } <IDNAME>;
    close (IDNAME);

print <<OMIMNAMEHEAD;
 <tr style="text-align: left;">
  <th>OMIM ID</th>
  <th>Symbol</th>
  <th>Description</th>
  <th>Link</th>
 </tr>
OMIMNAMEHEAD


    foreach $line_name (@lines_hit) {
	my ($id, $type, $symbol, $desc, $name) = split(/\t/, $line_name);

print <<OMIMNAME;
 <tr style="text-align: left;">
  <th>$id</th>
  <th>$symbol</th>
  <th>$desc</th>
  <th><a href="http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=$id">[NCBI]</a></th>
 </tr>
OMIMNAME

        push @symbol_list, $symbol;
	push @id_list, $id;
    }

    print "</table>"."\n";
    print "<br>"."\n";

    return(\@symbol_list, \@id_list);
}

sub printRelOmim {
    my (@omimids) = @_;

    print STDERR Dumper(@omimids) if ($debug == 2);

    $id_grep = "(".join("|", @omimids).")";

    print STDERR "[idgrep]\t".$id_grep."\n" if ($debug == 2);

    open (REL, "data/omim2omim.tab") or die $!;
    while (defined ($line_rel = <REL>)) {
	$line_rel =~ s/\r//;
	$line_rel =~ s/\n//;

	($self, $rel) = split(/\t/, $line_rel);
	if ($self =~ /^$id_grep$/) {
	    push @mim2mimRelatePre, ($rel);
	}
	elsif ($rel =~ /^$id_grep$/) {
	    push @mim2mimRelatePre, ($self);
	}
	else {

	}
    }
    close (REL);

    @mim2mimRelate = gendooCommon::uniqArray(@mim2mimRelatePre);

    if ($debug == 2) {
	print STDERR "[mim2mimRelate]"."\n";
	print STDERR Dumper(@mim2mimRelate);
    }

    open (ID2NAME, "data/omim.name.tab") or die $!;
    while (defined ($line_id2name = <ID2NAME>)) {
	$line_id2name =~ s/\r//;
	$line_id2name =~ s/\n//;

	$line_id2name =~ /^(\d+)\t/;
	$mimid_in = $1;
	$mim2name{$mimid_in} = $line_id2name;
    }
    close (ID2NAME);

    print $page->h2("Related OMIM Entry");
    print "<table border>"."\n";
    print " <tr>"."\n";
    print "  <th>OMIM ID</th>"."\n";
    print "  <th>Symbol</th>"."\n";
    print "  <th>Description</th>"."\n";
    print "  <th>Link</th>"."\n";
    print " </tr>"."\n";

    foreach $eachMim2mimRel (@mim2mimRelate) {
	$eachMim2mimRel =~ s/\r//;
	$eachMim2mimRel =~ s/\n//;

	$rel_entry = $mim2name{$eachMim2mimRel};
	my ($id, $type, $symbol, $desc) = split(/\t/, $rel_entry);

	print " <tr style=\"text-align: left\;\">"."\n";
	print "  <td>$id</th>"."\n";
	print "  <td>$symbol</th>"."\n";
	print "  <td>$desc</th>"."\n";
	print "  <td><a href=\"http://www.ncbi.nlm.nih.gov/entrez/dispomim.cgi?id=$id\">[NCBI]</a></td>"."\n";
	print " </tr>"."\n";

    }

    print "</table>"."\n";
    print $page->br();
    print $page->br();

}

sub printTable {
    my ($omim_ref, $symbol_ref, $ids_ref) = @_;

    my (@omim) = @$omim_ref;
    my (@symbols) = @$symbol_ref;
    my (@omimids) = @$ids_ref;

    if ($debug == 2) {
	print STDERR "[OMIM]".$_."\n" foreach @omim;
    }

    $omim_grep = "(".join("|", @omim).")";

    my (@rslts) = grepScore($omim_grep);

    print STDERR "[Results]\n".Dumper(@rslts) if ($debug == 2);


    print "<form method=GET action=\"gendoo.omim.cgi\">\n";
#    print "<input name=\"taxonomy\" type=\"hidden\" value=\"$taxonomy\">";

    printRelOmim(@omimids);

    ### Disease
    print $page->h2($page->a({name => "disease"}, "Disease"));
    tableHeader(@omimids);
    @rslts_disease = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /C/ } @rslts;
    tableBody(\@rslts_disease, \@omim, \@omimids);

    ### Chemicals
    print $page->h2($page->a({name => "chemical"}, "Chemicals"));
    tableHeader(@omim);
    @rslts_chemical = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /D/ } @rslts;
    tableBody(\@rslts_chemical, \@omim, \@omimids);

    ### Biological Phenomena
    print $page->h2($page->a({name => "biolphenom"}, "Biological Phenomena"));
    tableHeader(@omim);
    @rslts_biol = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /G/ } @rslts;
    tableBody(\@rslts_biol, \@omim, \@omimids);

    ### Anatomy
    print $page->h2($page->a({name => "anatomy"}, "Anatomy"));
    tableHeader(@omim);
    @rslts_anatomy = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /A\d{2}/ } @rslts;
    tableBody(\@rslts_anatomy, \@omim, \@omimids);

    ### Organisms
    print $page->h2($page->a({name => "organism"}, "Oragnisms"));
    tableHeader(@omim);
    @rslts_organisms = grep { $_ =~ /\t([^\t]*)$/; $1 =~ /B/ } @rslts;
    tableBody(\@rslts_organisms, \@omim, \@omimids);
}

sub htmlFooter {

    print "</form>";
    print $page->hr();
    print "<p style=\"text-align: right\;\">Database Center for Life Science</p>";
    print $page->end_html;
}

sub tableHeader {
    my (@omim) = @_;

print <<DHEADER;
<table border>
 <tr>
  <th><br></th>
  <th>MeSH terms</th>
  <th>Link</th>
DHEADER

    foreach $each_symbol (@omim) {
	$each_symbol = lc($each_symbol);
	$each_symbol =~ s/\s/<br>/g;

	print "<th style=\"font-size: 9pt\;\">$each_symbol</th>\n";
	print "<!-- <th>p-value</th> -->\n";
    }
    print "</tr>\n";
}

sub grepScore {
    my ($omim, $category) = @_;

    $category = "gene";

    print STDERR "[grep]".$omim."\n" if ($debug == 2);

    open (SCORE, "data/omim.mesh.score.tab") or die $!;
#    open (SCORE, "data/omim.mesh.score.$category.tab") or die $!;
    while (defined ($line_rslt = <SCORE>)) {
	if ($line_rslt =~ /\t$omim\t/) {
	    push @rslts, $line_rslt;
	}
#    @rslts = grep { @ele = split(/\t/, $_); $ele[3] =~ /^$omim$/ } <SCORE>;
    }
    close (SCORE);
#    $file_score = "/Library/WebServer/CGI-Executables/data/omim.mesh.score.tab";
#    @rslts = `grep \"\t$omim\t\" $file_score`;

    return (@rslts);
}

sub tableBody {
    my ($rslts_ref, $omim_ref, $omimid_ref, $category) = @_;
    my (@mesh_list) = ();

    my (@rslts) = @$rslts_ref;
    my (@omim) = @$omim_ref;
    my (@omim_id) = @$omimid_ref;
    my ($category) = "gene";

    print STDERR "[Rslts-sub]\n".Dumper(@rslts) if ($debug == 2);

    ### parse results
    foreach $each_rslt (@rslts) {
	$each_rslt =~ s/\r//;
	$each_rslt =~ s/\n//;

	my ($omimid, $ig, $pvalue, $omim_name, $mesh, $meshid) = split(/\t/, $each_rslt);

	$gm2score{$omim_name}->{$mesh} = [$ig, $pvalue];
	push @mesh_list, $mesh;
    }

    my (@mesh_uniq) = gendooCommon::uniqArray(@mesh_list);

    foreach $each_mesh (@mesh_uniq) {
	$mesh_link = $each_mesh;
	$mesh_link =~ s/\s/+/g;
	$mesh_link =~ s/^M://;

print <<DBODY1;
 <tr>
  <td><input name="mesh" type="checkbox" value="$each_mesh"></td>
  <td><a href="gendoo.omim.cgi\?mesh=$mesh_link">$each_mesh</a></td>
  <td><a href="http://www.ncbi.nlm.nih.gov/sites/entrez?Db=mesh&Cmd=DetailsSearch&Term=%22$mesh_link%22%5BMeSH+Terms%5D">[NCBI]</td>
DBODY1


	foreach $each_omim (@omim) {

	    if (defined ($gm2score{$each_omim}->{$each_mesh})) {
		my $score_ref = $gm2score{$each_omim}->{$each_mesh};

		($ig_ret, $pvalue_ret) = @$score_ref;

		print STDERR "[Score]\t".$ig_ret."\t".$pvalue_ret."\n" if ($debug == 2);

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
    print "<br><br><br>\n";
}

1;


#!/usr/bin/perl -w

# gendoo.cgi
# Nakazato T.
# '08-04-23-Wed.    Ver. 1
# '08-07-16-Wed.    Ver. 1.1
# '20-05-28_Thu.    Ver. 1.1001   fix XSS
# '20-08-19-Wed.    Ver. 1.1002   fix XSS
# '20-08-27-Thu.    Ver. 1.1003   fix XSS

use CGI;

my $debug = 1;

my $page = CGI->new();
$page->charset('utf-8');
$page = $page->escapeHTML($page);


# getArg
my @geneid_pre = $page->param('geneid');
my @genename_pre = $page->param('genename');
my $taxonomy   = $page->param('taxonomy');
my @meshid     = $page->param('meshid');
my @mesh_pre   = $page->param('mesh');
my @omim       = $page->param('omim');
my @omimid_pre = $page->param('omimid');
my $category   = $page->param('category');
my $view       = $page->param('view');

$taxonomy = xss($taxonomy);
$category = xss($category);
$view     = xss($view);


my @geneid;
my @omimid;

#@geneid = @geneid_pre if ($geneid_pre[0]);
if ($geneid_pre[0]) {
    @geneid = map {xss($_)} @geneid_pre;
}


if ($genename_pre[0]) {
    foreach $each_genename (@genename_pre) {
	$each_genename =~ s/\r//g;
	if ($each_genename =~ /^[\d\n]+$/) {
	    push @geneid, split(/\n/, $each_genename);
	}
	else {
	    my $genename_pre = $each_genename;
	    $genename_pre =~ s/\n/\|/g;
	    $genename_pre =~ s/\|+/\|/g;
	    $genename_pre =~ s/\|\s*$//;
	    $genename_pre = xss($genename_pre);

	    push @genenames_pre, ($genename_pre);
	}
    }
}

if ($omimid_pre[0]) {
    foreach $each_omimid (@omimid_pre) {
	$each_omimid =~ s/\r//g;
	if ($each_omimid =~ /^[\d\n\#\%\^\+\*]+$/) {
	    $each_omimid = xss($each_omimid);
	    push @omimid, split(/\n/, $each_omimid);
	}
	else {
	    my $omim_pre = $each_omimid;
	    $omim_pre =~ s/\n/\|/g;
	    $omim_pre =~ s/\|+/\|/g;
	    $omim_pre =~ s/\|\s*$//;
	    $omim_pre = xss($omim_pre);

#            push @omim_pre, ($omim_pre);
	    @omims_pre = ($omim_pre);
	}
    }
}

if ($mesh_pre[0]) {
    foreach $each_mesh (@mesh_pre) {
	$each_mesh =~ s/\r//g;
    	if ($each_mesh =~ /[ABCDG]\d{6}/) {
	    push @meshid, split(/\n/, $each_meshid);
	}
	else {
	    my $mesh_pre = xss($each_mesh);
	    push @mesh, $mesh_pre;
	}	
    }
}

my @genename = @genenames_pre;

#my @genename = (@genenames_pre, @genename);
@omim = (@omims_pre, @omim);
@omim = map { xss($_) } @omim;

if ($genename[0]) {
    print STDERR "DEBUG: GeneName" if $debug == 2;
    require "./genename2list.pm";
    genename2list::call(\@genename, $taxonomy);
}

elsif (($geneid[0]) and ($view eq "tree")) {
    require "./geneid2tree.pm";
    geneid2tree::call(\@geneid, $category, $taxonomy);
}
elsif ($geneid[0]) {
    print STDERR "DEBUG: GeneID" if $debug == 2;
    require "./geneid2score.pm";
    geneid2score::call(\@geneid, $taxonomy);
}
elsif ($mesh[0]) {
    require "./meshterm2list.pm";
    meshterm2list::call(\@mesh, $taxonomy);
}
elsif ($meshid[0]) {
    require "./meshid2score.pm";
    meshid2score::call(\@meshid, $taxonomy);
}
elsif ($omim[0]) {
    require "./omimtitle2list.pm";
    omimtitle2list::call(\@omim);
}
elsif (($omimid[0]) and ($view eq "tree")) {
    require "./omimid2tree.pm";
    omimid2tree::call(\@omimid, $category);
}
elsif ($omimid[0]) {
    require "./omimid2score.pm";
    omimid2score::call(\@omimid);
}
else {
    print $page->redirect(-url => '../index.html');
}


sub xss {
    my ($str) = @_;

    $str =~ s/&/\&amp;/g;
    $str =~ s/</\&lt;/g;
    $str =~ s/>/\&gt;/g;
    $str =~ s/"/\&quot;/g;
    $str =~ s/'/\$#x27;/g;
    $str =~ s/\//\&#x2F;/g;

    return $str;
}

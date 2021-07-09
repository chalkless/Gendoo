#!/usr/bin/perl

# gendoo.omim.cgi
# Nakazato T.
# '07-10-15-Mon.    Ver. 0
# '07-10-16-Tue.    Ver. 0.1    id -> rslt, name -> id, mesh -> gene
# '07-10-24-Wed.    Ver. 0.2    mesh list
# '07-10-31-Wed.    Ver. 0.3    for omim

use CGI;
use Data::Dumper;

my $debug = 1;

$page = CGI->new();
print "Content-type: text/html\n\n";
($omim_ref, $omim_list_ref, $mesh_ref, $mesh_list_ref) = getArg();
if ($debug == 2) {
    print STDERR "[OMIM]\n".Dumper($omim_ref);
    print STDERR "[OMIM_list]\n".Dumper($omim_list_ref);
    print STDERR "[MeSH]\n".Dumper($mesh_ref);
    print STDERR "[mesh_list]\n".Dumper($mesh_list_ref);
}

@omim = @$omim_ref;
@omimname = @$omim_list_ref;
@mesh = @$mesh_ref;
@mesh_list = @$mesh_list_ref;

if ($omim[0]) {
    callOmimToMeSH(\@omim);
}
elsif ($omimname[0]) {
    callOmimToList(\@omimname);
}
elsif ($mesh[0]) {
    callMeSHToOmim(\@mesh);
}
elsif ($mesh_list[0]) {
    callMeSHToList(\@mesh_list);
}
else {
    print STDERR "No Arg!"."\n";
}

exit;




sub getArg {
    if (@ARGV) {
	print "! ARGV !"."\n" if ($debug == 2);
	my $geneid = shift @ARGV;
    } elsif ($ENV{'REQUEST_METHOD'}) {
	if ($debug == 2) {
	    while (my ($key, $value) = each (%ENV)) {
		print "[$key]\t".$value."<br>\n";
	    }
	}

	@omim = $page->param('omim');
	@omimname = $page->param('omim_list');
	@mesh = $page->param('mesh');
        @mesh_list = $page->param('mesh_list');
	$category = $page->param('category');
    }

    return(\@omim, \@omimname, \@mesh, \@mesh_list);
}

### Error check


### Result
sub callOmimToMeSH {
    my ($omim_ref) = @_;

    print STDERR Dumper($omim_ref) if ($debug == 2);

    require "./omim2mesh.pm";
    omim2mesh::call($omim_ref);
}

sub callOmimToList {
    my ($omim_list_ref) = @_;

    print STDERR Dumper($omim_list_ref) if ($debug == 2);

    require "./omimName2list.pm";
    omimName2list::call($omim_list_ref);
}

sub callMeSHToOmim {
    my ($mesh_ref) = @_;

    print "[Main::Name]\t".$mesh_ref."<br>\n" if ($debug == 2);

    require "./mesh2omim.pm";
    mesh2omim::call($mesh_ref);
}

sub callMeSHToList {
    my ($mesh_list_ref) = @_;

    require "./meshName2listOmim.pm";
    meshName2listOmim::call($mesh_list_ref);
}


1;

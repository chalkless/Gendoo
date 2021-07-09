#!/usr/bin/perl

# gendoo.cgi
# Nakazato T.
# '07-10-15-Mon.    Ver. 0
# '07-10-16-Tue.    Ver. 0.1    id -> rslt, name -> id, mesh -> gene
# '07-10-24-Wed.    Ver. 0.2    mesh list


use CGI;
use Data::Dumper;

my $debug = 1;

$page = CGI->new();
print "Content-type: text/html\n\n";
($geneid_ref, $name_ref, $mesh_ref, $mesh_list_ref, $taxonomy) = getArg();
if ($debug == 2) {
    print STDERR "[GeneID]\n".Dumper($geneid_ref);
    print STDERR "[Name]\n".Dumper($name_ref);
    print STDERR "[MeSH]\n".Dumper($mesh_ref);
    print STDERR "[mesh_list]\n".Dumper($mesh_list_ref);
}

@geneid = @$geneid_ref;
@name = @$name_ref;
@mesh = @$mesh_ref;
@mesh_list = @$mesh_list_ref;


if ($geneid[0]) {
    callIdToRslt(\@geneid, $taxonomy);
} elsif ($name[0]) {
    callNameToList(\@name, $taxonomy);
} elsif ($mesh[0]) {
    callMeSHToRslt(\@mesh, $taxonomy);
} elsif ($mesh_list[0]) {
    callMeSHToList(\@mesh_list, $taxonomy);
} else {

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

	@geneid = $page->param('geneid');
	@name = $page->param('name');
	@mesh = $page->param('mesh');
        @mesh_list = $page->param('mesh_list');
	$taxonomy = $page->param('taxonomy');
    }

    return(\@geneid, \@name, \@mesh, \@mesh_list, $taxonomy);
}

### Error check


### Result
sub callIdToRslt {
    my ($geneid_ref, $taxonomy) = @_;

    print STDERR Dumper($geneid_ref) if ($debug == 2);

    require "./id2rslt.pm";
    id2rslt::call($geneid_ref, $taxonomy);
}

sub callNameToList {
    my ($name_ref, $taxonomy) = @_;

    print "[Main::Name]\t".$name_ref."<br>\n" if ($debug == 2);

    require "./name2list.pm";
    name2list::call($name_ref, $taxonomy);
}

sub callMeSHToRslt {
    my ($mesh_ref, $taxonomy) = @_;

    print "[Main::Name]\t".$mesh_ref."<br>\n" if ($debug == 2);

    require "./mesh2gene.pm";
    mesh2gene::call($mesh_ref, $taxonomy);
}

sub callMeSHToList {
    my ($mesh_list_ref, $taxonomy) = @_;

    require "./meshName2list.pm";
    meshName2list::call($mesh_list_ref, $taxonomy);
}


1;

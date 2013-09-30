#!/usr/bin/perl

# format.pair2each.pl
# Nakazato T.
# '08-03-07-Fri.    Ver. 0      original: format.pair2each.pl
# '13-09-30-Mon.    Ver. 0.1    refined


$debug = 1;

my ($file_in) = $ARGV[0];

open (IN, $file_in) or die $!;
while (defined ($line_in = <IN>)) {
    $line_in =~ s/[\r\n]//g;

    my ($mimid, $pmid) = split(/\t/, $line_in);

    if ($mimid_pre eq $mimid) {
        push @pmids, $pmid;
    }
    else {
        if (@pmids) {
            $pmids_out = join("\|", @pmids);
            print join("\t", $mimid_pre, $pmids_out)."\n";
        }

        @pmids = ($pmid);

        $mimid_pre = $mimid;
    }
}
close (IN);

if (@pmids) {
    $pmids_out = join("\|", @pmids);
    print join("\t", $mimid_pre, $pmids_out)."\n";
}



#!/usr/bin/perl

# ext.subst2refseq.pl
# Nakazato T.
# '08-02-04-Mon.    Ver. 0
# '13-09-11-Wed.    Ver. 0.1


$debug = 1;

# IN: MeSH subst file: c2013.bin
my ($file_subst) = shift @ARGV;
open (SUBST, $file_subst) or die $!;
while (defined ($line_subst = <SUBST>)) {
    $line_subst =~ s/[\r\n]//;

    if ($line_subst =~ /^NM = (.*)/) {
        $subst = $1;      # Substance Names
    }
    elsif (($line_subst =~ /^NO = (.*)/)
           or ($line_subst =~ /^SO = (.*)/)
           or ($lien_subst =~ /^RN = (.*)/)) {
        $ele_tmp = $1;    # extracting RefSeq ID candidate

        @ele_tmp = split(/\;/, $ele_tmp);
        push @ele, @ele_tmp;
    }
    elsif ($line_subst =~ /^UI = (.*)/) {
        $id = $1;         # Subst ID

        foreach $each_ele (@ele) {
            $each_ele =~ s/^\s*(.*)\s*$/$1/;
	    while ($each_ele =~ /([A-Z]+_{0,1}\d+)/) {
		$acc_tmp = $1;

		if ($acc_tmp =~ /([A-Z]{2}_\d+)/) {
		    $refseq_tmp = $1;
		    print join("\t", $id, $subst, $refseq_tmp, "R")."\n";
		}
		else {
		    print join("\t", $id, $subst, $acc_tmp, "A")."\n";
		}
		$each_ele =~ s/$acc_tmp//;
	    }	    
        }
        undef @ele;
	undef @ele_tmp;
    }
}
close (SUBST);

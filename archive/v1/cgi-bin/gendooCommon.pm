#!/usr/bin/perl

# score2style.pm
# Nakazato T.
# '07-10-27-Sat.    Ver. 0

package gendooCommon;

use Exporter;
@ISA=(Exporter);
@EXPORT = qw(score2style uniqArray);

my $debug = 1;

if (@ARGV) {
    my ($score) = @ARGV;
    my ($style) = score2style($score);
    print $style."\n";
    exit;
}

sub score2style {
    my ($pvalue) = @_;

    if ($pvalue == 1) {
        $style = "score16";
    } elsif ((0.75 <= $pvalue) and ($pvalue < 1 )) {
        $style = "score15";
    } elsif ((0.50 <= $pvalue) and ($pvalue < 0.75 )) {
        $style = "score14";
    } elsif ((0.40 <= $pvalue) and ($pvalue < 0.50 )) {
        $style = "score13";
    } elsif ((0.30 <= $pvalue) and ($pvalue < 0.40 )) {
        $style = "score12";
    } elsif ((0.20 <= $pvalue) and ($pvalue < 0.30 )) {
        $style = "score11";
    } elsif ((0.10 <= $pvalue) and ($pvalue < 0.20 )) {
        $style = "score10";
    } elsif ((0.05 <= $pvalue) and ($pvalue < 0.10 )) {
        $style = "score09";
    } elsif ((10e-2 <= $pvalue) and ($pvalue < 0.05 )) {
        $style = "score08";
    } elsif ((10e-3 <= $pvalue) and ($pvalue < 10e-2 )) {
        $style = "score07";
    } elsif ((10e-4 <= $pvalue) and ($pvalue < 10e-3 )) {
        $style = "score06";
    } elsif ((10e-5 <= $pvalue) and ($pvalue < 10e-4 )) {
        $style = "score05";
    } elsif ((10e-6 <= $pvalue) and ($pvalue < 10e-5 )) {
        $style = "score04";
    } elsif ((10e-7 <= $pvalue) and ($pvalue < 10e-6 )) {
        $style = "score03";
    } elsif ((10e-8 <= $pvalue) and ($pvalue < 10e-7 )) {
        $style = "score02";
    } elsif ((10e-9 <= $pvalue) and ($pvalue < 10e-8 )) {
        $style = "score01";
    } elsif ((10e-10 <= $pvalue) and ($pvalue < 10e-9 )) {
        $style = "score01";
    } elsif ($pvalue < 10e-10 ) {
        $style = "score01";
    } else {
        $style = "score08";
    }

    return ($style);
}


sub uniqArray {
    my (@array_pre) = @_;

    @array_uniq = ();
    %hash = ();

    foreach $element (@array_pre) {
        if (defined ($hash{$element})) {

        } else {
            $hash{$element} = 1;
            push @array_uniq, $element;
        }
    }
    return @array_uniq;
}

1;

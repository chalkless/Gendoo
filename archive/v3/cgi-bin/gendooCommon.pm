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
    my ($pvalue, $view) = @_;

    my ($style_view, $style);

    if ($view eq "list") {
	$style_view = "List";
    }
    elsif ($view eq "tree") {
	$style_view = "Tree";
    }


    if ($pvalue == 1) {
        $style = "score".$style_view."16";
    } elsif ((0.75 <= $pvalue) and ($pvalue < 1 )) {
        $style = "score".$style_view."15";
    } elsif ((0.50 <= $pvalue) and ($pvalue < 0.75 )) {
        $style = "score".$style_view."14";
    } elsif ((0.40 <= $pvalue) and ($pvalue < 0.50 )) {
        $style = "score".$style_view."13";
    } elsif ((0.30 <= $pvalue) and ($pvalue < 0.40 )) {
        $style = "score".$style_view."12";
    } elsif ((0.20 <= $pvalue) and ($pvalue < 0.30 )) {
        $style = "score".$style_view."11";
    } elsif ((0.10 <= $pvalue) and ($pvalue < 0.20 )) {
        $style = "score".$style_view."10"
    } elsif ((0.05 <= $pvalue) and ($pvalue < 0.10 )) {
        $style = "score".$style_view."09";
    } elsif ((10e-2 <= $pvalue) and ($pvalue < 0.05 )) {
        $style = "score".$style_view."08";
    } elsif ((10e-3 <= $pvalue) and ($pvalue < 10e-2 )) {
        $style = "score".$style_view."07";
    } elsif ((10e-4 <= $pvalue) and ($pvalue < 10e-3 )) {
        $style = "score".$style_view."06";
    } elsif ((10e-5 <= $pvalue) and ($pvalue < 10e-4 )) {
        $style = "score".$style_view."05";
    } elsif ((10e-6 <= $pvalue) and ($pvalue < 10e-5 )) {
        $style = "score".$style_view."04";
    } elsif ((10e-7 <= $pvalue) and ($pvalue < 10e-6 )) {
        $style = "score".$style_view."03";
    } elsif ((10e-8 <= $pvalue) and ($pvalue < 10e-7 )) {
        $style = "score".$style_view."02";
    } elsif ((10e-9 <= $pvalue) and ($pvalue < 10e-8 )) {
        $style = "score".$style_view."01";
    } elsif ((10e-10 <= $pvalue) and ($pvalue < 10e-9 )) {
        $style = "score".$style_view."01";
    } elsif ($pvalue < 10e-10 ) {
        $style = "score".$style_view."01";
    } else {
        $style = "score".$style_view."08";
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

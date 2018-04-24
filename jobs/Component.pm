#! /usr/bin/perl

use strict;
use Text::ParseWords;

require "common.pm";
require "LogUtil.pm";

package Component;

sub new {
    my $class = shift;
    my $name = shift;
    my $component_config = shift;

    my $component = {
        type   => __PACKAGE__,
        name   => $name,
        config => $component_config
    };

    bless $component, $class;
    return $component;
}

sub check_condition {
    my $self = shift;
    my $job_condition_str = shift;

    print "stwu debug: job condition string is: $job_condition_str\n";
    my @job_condition_split = split /\./, $job_condition_str;
    LogUtil::dump("job_condition str:\n", \@job_condition_split);
    my $condition_str = $job_condition_split[1];
    print "stwu debug: condition str is: $condition_str\n";
    # $condition_str =~ s/[()]/"/g;
    print "stwu debug: condition str is: $condition_str\n";
    # my @condition_split = &main::quotewords(",", 0, $condition_str);
    my @condition_split = split /[(),]/, $condition_str;
    my $condition = shift @condition_split;
    foreach (@condition_split) {
        $_ =~ s/(^\s+|\s+$)//g;
    }
    common::run_condition($job_condition_split[0], $condition, @condition_split);
}

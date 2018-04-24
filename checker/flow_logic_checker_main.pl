#! /usr/bin/perl

use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case);

require "flow_logic_checker.pm";

sub main {
    my $flowxml = "/Users/wuge/my_practice/perl_practice/flow_control_practice/test1.xml";
    my @opt_list = ("f=s");
    my %opts;

    my $ret = GetOptions(\%opts, @opt_list);
    $flowxml = $opts{f} if $opts{f};
    my $checker = FlowLogicChecker->new($flowxml);
    $checker->check();
}

&main;

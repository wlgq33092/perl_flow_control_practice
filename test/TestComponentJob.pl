#! /usr/bin/perl

use strict;

use GetOpt::Long qw(:config_no_ignore_case);
use Test::More tests => 20;

my $srcdir;
if (defined $ENV{FLOWDIR}) {
    $srcdir = $ENV{FLOWDIR};
} else {
    $srcdir = "/Users/wuge/my_practice/perl_practice/flow_control_practice";
}

unshift @INC, "$srcdir/engine";
unshift @INC, "$srcdir/parser";
unshift @INC, "$srcdir/utils";
unshift @INC, "$srcdir/jobs";

require "Component.pm";
require "switcher.pm";

sub test_main {
    my $config = {
        a => "b",
        c => "d"
    };
    # my $component = Component->new("component1", $config);
    # $component->check_condition("job1.check_defect(100, 20)");
    # $component->check_condition("job2.conditional_start(80,30)");

    my $switcher1 = switcher->new("switcher1", $config);
    $switcher1->check_condition("job1.check_defect(100, 20)");
}

&test_main;

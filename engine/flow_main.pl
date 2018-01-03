#! /usr/bin/perl

use strict;

use GetOpt::Long qw(:config_no_ignore_case);

sub main {
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

    require "flow_engine.pm";
    require "flow_parser.pm";

    print "main\n";

    # run flow parser
    


    # run flow engine
    my $engine = &FlowEngine::new;
    my $xml1 = "/Users/wuge/my_practice/perl_practice/flow_control_practice/test1.xml";
    $engine->build_jobs($xml1);
    $engine->run();
}

&main;

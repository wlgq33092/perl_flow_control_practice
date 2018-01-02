#! /usr/bin/perl

require "Flow.pm";
require "flow_parser.pm";

unshift @INC ../;
unshift @INC ../parser;
unshift @INC ../utils;

sub main {
    print "main\n";
    my $flow = Flow->new;
    my $xml1 = "/Users/wuge/my_practice/perl_practice/flow_control_practice/test1.xml";
    $flow->build_jobs($xml1);
    $flow->run();
}

&main;

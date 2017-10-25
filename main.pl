#! /usr/bin/perl

require "Flow.pm";
require "flow_parser.pm";

sub main {
    print "main\n";
    my $flow = Flow->new;
    my $xml1 = "/Users/wuge/my_practice/perl_practice/flow_control_practice/test1.xml";
    my $joba = $flow->load_job("joba");

    $flow->load_job("jobb");
    $flow->load_job("jobc");
    #$flow->build_jobs("/Users/wuge/my_practice/perl_practice/flow_control_practice/test1.xml");
    #$flow->build_flow();
    #$flow->run();
    my $parser = flow_parser->new($xml1);
    $parser->parse();
}

&main;

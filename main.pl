#! /usr/bin/perl

require "Flow.pm";

sub main {
    print "main\n";
    my $flow = Flow->new;
    my $joba = $flow->load_job("joba");

    $flow->load_job("jobb");
    $flow->load_job("jobc");
    $flow->build_flow();
    $flow->run();
}

&main;

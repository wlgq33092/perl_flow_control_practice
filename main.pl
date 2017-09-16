#! /usr/bin/perl

require "Flow.pm";

sub main {
    print "main\n";
    my $flow = Flow->new;
    my $joba = $flow->load_job("joba");
    $joba->next();
}

&main;

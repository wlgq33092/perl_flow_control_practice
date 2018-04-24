#! /usr/bin/perl

use strict;

use GetOpt::Long qw(:config_no_ignore_case);
use Test::More;
use base qw(Test::Class);
#use Test::Class;

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
require "parser_result.pm";
require "LogUtil.pm";

my $test_flow_parser;
my $test_flowxml_result;
my $test_engine;

sub make_result : Test(startup) {
    my $flow_log = LogFlow->new($srcdir . "/test/flow.log");

    my $test_config_file = "/Users/wuge/my_practice/perl_practice/flow_control_practice/test2.xml";
    $test_flow_parser = FlowXMLParser->new($test_config_file);
    $test_flowxml_result = $test_flow_parser->parse();

    my $parser = FlowParser->new();
    my $parser_res = $parser->parse();

    # init engine kernel
    $test_engine = FMOEngineKernel->new($parser_res, $flow_log);
}

sub shutdown : Test(shutdown) {
    print "Test result finish.\n";
}

sub test_next_job {
    my $src_job_name = shift;
    my $exp_job_name = shift;

    print "test $src_job_name's next job.\n";
    my $next_job = $test_engine->get_next_jobs($src_job_name);
    is($next_job, $exp_job_name, "$src_job_name next job test");
}

sub test_job_configuration {
    my ($test_job_config, $exp_name, $exp_type, $exp_next) = @_;
    test_next_job("job1", "job2");
    test_next_job("job2", "switcher1");
    test_next_job("job3", "DONE");
}

sub test_flowxml_parser : Test {
    &test_job_configuration;
}

sub test_main {
    Test::Class->runtests;
}

&test_main;
